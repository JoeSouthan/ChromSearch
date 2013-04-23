package ChromoDB;

use strict;
#use warnings;

use DBI;
use Data::Dumper;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(GetSearchResults DatabaseConnect GetIdentifier DoQuery QuerySearch IsArrayEmpty
	BuildCodingSeq GetCodons FindRES SetLastErrorMessage GetLastErrorMessage QuerySequence
	CalculateCodonUsage);

# Global variables

# global to store the last error
my $lastErrorMessage = '';

# CALLED FROM WEBSITE

##########################################################################################################
#
# GetSearchResults - Takes input string for an identifier from the webpage and searches the database for matches
#
##########################################################################################################
sub GetSearchResults( $$$ ){
	
	# Get and store the input arguments, $class because of SOAP calling it.
	my ($searchString, $idType, $browseMode) = @_;
	
	my %error = ();
	
	# Check for blank arguments passed in
	if(($searchString eq '') || ($idType eq '')){
		$error{'error'} = 'ERROR:ZERO_LENGTH_ARGUMENT';
		return %error;
	}
	
	# Convert requested identifier type to a DB column name
	my $id = GetIdentifier($idType);
	unless( $id ){
		$error{'error'} = GetLastErrorMessage();
		return %error;
	}
	
	# Send a search query to the DB
	my @queryResult = QuerySearch($searchString, $id, $browseMode);
	
	# String must contain matches to return
	unless( $queryResult[0] ){

		# If is null return null string or error code
		$error{'error'} = GetLastErrorMessage();
		# Return error string
		return %error; 	
		
	}else{
		# Hash to hold the data associated with each search results accessionNo
		my %searchResults;
	
		for(my $i = 0; $i < @queryResult; $i++){
			# Name each entry by accession number
			my $accessionNumber = $queryResult[$i]->[0];
			
			# Fill out the hash entry with all the data associated with the accessionNo
			$searchResults{$accessionNumber}{'GeneName'} = $queryResult[$i]->[1];
			$searchResults{$accessionNumber}{'ChromosomeLocation'} = $queryResult[$i]->[2];
			$searchResults{$accessionNumber}{'ProteinName'} = $queryResult[$i]->[3];
			$searchResults{$accessionNumber}{'ProteinId'} = $queryResult[$i]->[4];
			$searchResults{$accessionNumber}{'GeneLength'} = $queryResult[$i]->[5];
			
			
			# Get the DNA seq
			my $DNASeq = QuerySequence($accessionNumber, 'geneSeq');
			if( $DNASeq ){
				$searchResults{$accessionNumber}{'DNASeq'} = $DNASeq;
			}else{
				$searchResults{$accessionNumber}{'DNASeq'} = 'N/A'
			}
			
			# Get the amino acid sequence
			my $AASeq = QuerySequence($accessionNumber, 'proteinSeq');
			if( $AASeq ){
				$searchResults{$accessionNumber}{'AASeq'} = $AASeq;
			}else{
				$searchResults{$accessionNumber}{'AASeq'} = 'N/A'
			}
			
			# Retrieve coding sequence data for given accession number
			# Need error checking for below and a messge to indicate if there
			# is no data.
			my @sequence = BuildCodingSeq($queryResult[$i]->[0]);
			$searchResults{$accessionNumber}{'SeqFeat'} = [@sequence];
			
			# Retrieve codon usage data
	
			# Attempt to retrieve the codons for the given accession number
			my @codons = GetCodons( $queryResult[$i]->[0] );
			
			unless( @codons ){
			# No codons returned list as empty
			$searchResults{$accessionNumber}{'CodonUsage'} = 'N/A';
			}else{
				# Valid array of codons converted to percentages and packaged in to hash
			$searchResults{$accessionNumber}{'CodonUsage'} = [CalculateCodonUsage(@codons)];
			}
		}

		# Return the hash to JSON
		return %searchResults;

	}
	
}

##########################################################################################################
#
# GetRES - Takes no arguments and returns a list of RES with name and cutsite
#
##########################################################################################################
sub GetRES{

	# Attempt to retrieve all REsites from the DB
	my @reSites = FindRES();
	
	my %error = ();
	
	# Chech that something was entered in to the array of sites
	unless( @reSites ){
		# If not return error message
		$error{'error'} = 'NO_RESITES_FOUND'; 
		return %error;
	}
	
	# Hash for restriction sites 
	my %restrictionSites;
	
	foreach my $res (@reSites){
		# Assignb name for hash key
		my $resName = $res->[0];
		# Assign cut site for hash value
		$restrictionSites{$resName} = $res->[1];
	}

	# Return all restriction site information to caller
	return %restrictionSites;
}

# FUNCTIONS CALLS TO DB

##########################################################################################################
#
# DatabaseConnect - Takes database name, username, password and server name, returns handle to DB or undef.
# let the caller handle success and fail of connect.
#
##########################################################################################################
sub DatabaseConnect{
	
	#Defined the connection details to the database
	# my $dbname = 'scouls01'; 
	# my $user = 'scouls01';
	# my $password = 'iwr8sh8vb'; 
	# my $dbserver = 'localhost';
	
	 my $dbname = 'biocomp2'; 
	 my $user = 'c2';
	 my $password = 'coursework123'; 
	 my $dbserver = 'localhost';
	
	# Specify the location and name of the database
	my $datasource = "dbi:mysql:database=$dbname;host=$dbserver;";
	
	
	# Attempt to connect to the database (turn off DBI error reporting )
	my $dbh = DBI->connect($datasource, $user, $password, {PrintError => 0});
	
	# If succesful connect return the handle if not return undefined
	# Note: connect only seems to care that password is present will still
	# return true if user is missing
	if( defined($dbh) )
	{
		# Return handle to database
		return $dbh;
	}else{
		# Show why DBI-connect failed
		#print DBI->errstr;
		return undef;
	}
}

##########################################################################################################
#
# GetIdentifier - Takes an indentifer and returns an indentifer that complies with the DB column names.
#
##########################################################################################################
sub GetIdentifier{
	
	# Assumes that a valid string has been passed (ChromoDB checks this)
	my ($id, $idType) = $_[0], undef;
	
	# Attempt to match the input name to the a column id
	if( $id eq "GeneID" ) {
		$idType = "geneId";
	}elsif($id eq "ProteinProduct"){
		$idType = "proteinName";
	}elsif($id eq "AccessionNumber"){
		$idType = "accessionNo";
	}elsif($id eq "ChromosomeLocation"){
		$idType = "chromLoc";
	}elsif($id eq "GeneSeq"){
		$idType = "geneSeq";
	}elsif($id eq "ProteinSeq"){
		$idType = "proteinSeq";
	}else{
		# If nothing matched set error and return undefined
		SetLastErrorMessage('ERROR:UNRECOGNIZED_ID');
		return undef;
	}
	
	# If a match is found then this will return the match.
	return $idType;
}

##########################################################################################################
#
# DoQuery - Takes a MySQL query string, returns the result from the query in an array
#
##########################################################################################################
sub DoQuery( $ ){

	# Get query string from function argument
	my $sqlQuery = $_[0];
	
	# Attempt to connect to database 
	my $hDb = DatabaseConnect();
	if( $hDb ){
		
		# Array to hold output
		my @rowData;
		
		# Get a handle to the executing statement
		my $queryRows = $hDb->prepare( $sqlQuery );
	
		# Run query
		if($queryRows->execute)
		{
			# Check query went ok
			if ( !$queryRows )
			{
				$hDb->errstr;
				
				# If an error occured passback custom error message and exit.
				SetLastErrorMessage('ERROR:DB_QUERY');
				return undef;
			}else{
				# Store a reference to an array of references for each row in the DB
				while( my @data = $queryRows->fetchrow_array() ){
					# Create 2D array to hold data for each row.
					push @rowData, [ @data ];
				}	
			}
				
		}
		# Finished using database disconnect
		$hDb->disconnect();
		
		# Use isArrayFunction to check for 'empty' array.  The MySQL entries will
		# always have something as their value, here if the array is full of 
		# N/A entries then return custom message indicating no data and exit.
		if( IsArrayEmpty( @rowData ) eq 0 ){
			SetLastErrorMessage('DB_RETURNED_NO_MATCHES');
			return undef;
		}else{
			# Return data in raw array form, let caller extract the required information
			return @rowData;
		}
	}else{
		# Could not connect to database,s et error and return undefined
		SetLastErrorMessage('ERROR:NO_DB_CONNECTION');
		return undef;
	}
}

##########################################################################################################
#
# QuerySearch - Takes a search string and type, returns comma separated list of search results
#
##########################################################################################################
sub QuerySearch( $$$ ){
	
	# Get the function parameters, assumes valid non-zero string and valid identifier input
	my ($searchString, $idType, $browseMode) = @_;
	
	my $sqlQuery = '';
	
	if( 0 == $browseMode ){
		# Run search query **$searchstring must be in quotes***
		$sqlQuery = "SELECT accessionNo, geneId, chromLoc, proteinName, ProteinId, geneSeqLen FROM gene WHERE $idType LIKE '%$searchString%'";
	}else{
		$sqlQuery = "SELECT accessionNo, geneId, chromLoc, proteinName, ProteinId, geneSeqLen FROM gene WHERE $idType LIKE '$searchString%'";
	}
	
	# Run query
	my @searchResults = DoQuery($sqlQuery);
	
	unless( @searchResults ){
		# If the array is not defined an error occured, return undef
		# to signal to caller to check the last error.
		return undef;
	}else{
		# Array was defined return the results.
		return @searchResults;
	}
}  

##########################################################################################################
#
# IsArrayEmpty - Takes an array as input and returns true if it is empty or false if not empty
#
##########################################################################################################
sub IsArrayEmpty( @ ){
	
	# Get copy of passed in array
	my @array = @_;
	
	# Get length of array, loop through array and test if each entry is valid or 'N/A'
	# If all are 'N/A' then the coloumn is effectively empty.
	for( my $i = 0; $i < @array; $i++ ){
		
		for( my $j = 0; $j < $#{$array[$i]}+1; $j++ ){
		
			# If not zero length or is not equal to N/A trigger return
			# At least one item was found in the returned array.
			
			if( ( length($array[$i][$j]) ) && ($array[$i][$j] ne 'N/A') )
			{
				return 1; # Has length or is not equal to N/A
			}
		}
	}
	# All item were zero length or N/A, array was empty, return 0 for success or has data
	return 0;
}

###############################################################################################
#
# BuildCodingSeq - Takes an accession number and returns an array with all the introns and exons in sequence.
#
###############################################################################################
sub BuildCodingSeq{

	# Get accession number for DB lookup
	my $accessionNo = $_[0];
	
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuery = "SELECT featStart, featEnd FROM seqFeat WHERE accessionNo='$accessionNo'
	ORDER BY LENGTH(featStart)";
	
	# Fetch the exon coding sequence information from DB, array will progress as 
	# Type, start, stop then repeat for next item.
	my @tableRows = DoQuery($sqlQuery);
	unless( @tableRows ){
		SetLastErrorMessage('ERROR:DB_COLUMN_EMPTY');
		return undef;
	}
	
	# Get the length of the sequence
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuerySeqlength = "SELECT geneSeqLen FROM gene WHERE accessionNo='$accessionNo'";
	
	
	my @sequenceLength = DoQuery($sqlQuerySeqlength);
	unless( @sequenceLength ){
		SetLastErrorMessage('ERROR:DB_COLUMN_EMPTY');
		return undef;
	}
	
	#print Dumper(@tableRows);
	#print $sequenceLength[0][0],"\n";
	
	# Read array and cut the sequence up according to the start stop sequence features,
	# let MySQL query string do the ordering
	
	# Array to hold final data that is passed back to caller
	my @CDSarray;
	
	# Used to track position in array
	my $tableRowIndex = 0; 
	
	
	# All entries are exons, all non-coding introns are inferred from the data and must 
	# be present in the final array.
	
	# Deal with first entry outside of loop as it is a bit inefficient to run the check
	# every iteration of the loop below.
	
	# Is first entry an exon? If so, does it start at one? 
	if( '1' == $tableRows[0][0] ){
	
		# If yes, then sequecne starts with exon.
		# Get first and second numbers of first entry and format them into a string
		my $entry = join("","EXON;",$tableRows[0][0],":",$tableRows[0][1]);
		push(@CDSarray, $entry);
		
		# In the event that the first entry is the only entry
		if(defined($tableRows[2])){
			# Set the segement follwing as an NCS
			my $ncsEntry = join("","NCS;",$tableRows[0][1]+1,":",$tableRows[1][0]-1);
			push(@CDSarray, $ncsEntry);
		}else{
			# This is the only entry so set rest of sequecne as NCS.
			my $ncsEntry = join("","NCS;",$tableRows[0][1]+1,":",$sequenceLength[0][0]);
			push(@CDSarray, $ncsEntry);
		}
		
	}else{
		# If no then infer an NCS and calculate NCS length.
		my $entry = join("","NCS;","0",":",$tableRows[0][0]-1);
		push(@CDSarray, $entry);
	}
	
	# Extract start and end positions of the exons, put them into array.
	for( my $i = $tableRowIndex; $i < scalar(@tableRows); $i++){
		
		# Temporary variables for the start and stop positions of the exons
		my ($segStart, $segStop); 
		
		# Get start number of current exon
		$segStart = $tableRows[$i][0];
		
		# Extract stop position of exon 
		$segStop = $tableRows[$i][1];
		
		# Write the start/stop information into the string
		my $entry = join("","EXON;",$segStart,":",$segStop);
		push(@CDSarray, $entry);
	
		# Find distance between current exon and next and denote as NCS if last in array.
		if( defined($tableRows[$i+1]) )
		{
			my $nextEntry = join("","INTRON;",$tableRows[$i][1]+1,":",$tableRows[$i+1][0]-1);
			push(@CDSarray, $nextEntry);
		}else{
			my $nextEntry = join("","NCS;",$segStop+1,":",$sequenceLength[0][0]);
			push(@CDSarray, $nextEntry);
		}
	}
	
	return @CDSarray;
}

##########################################################################################################
#
# GetCodons - Takes an accession number for a gene and returns an array of codons from the DB
#
##########################################################################################################
sub GetCodons( $ ){

	# Grab the accesion number for the genes codons we want
	my $accessionNo = $_[0];
	
	# Query for codons given the accession number
	my $sqlQuery = "SELECT codonCount FROM codonBias WHERE accessionNo = '$accessionNo'";
	
	# Run the query and save the result in a array
	my @accesionCodons = DoQuery($sqlQuery);
	
	return @accesionCodons;
}

##########################################################################################################
#
# GetlastErrorMessage - Takes no arguments and retruns the last error set in the global variables
#
##########################################################################################################
sub GetLastErrorMessage{
	return $lastErrorMessage;
}

##########################################################################################################
#
# SetLastErrorMessage - Takes an error string contining a message and set the global error message variable to this
#
##########################################################################################################
sub SetLastErrorMessage( $ ){
	if( $_[0] )
	{
		$lastErrorMessage = $_[0];
	}else{
		$lastErrorMessage = $_[0] = 'ERROR_UNDEFINED';
	}
}

###############################################################################################
#
# FindRES -  Returns a list RES (names and cut sites) in the DB.  
#
###############################################################################################
sub FindRES{
	
	# Query to return all the current restriction enzymes in the database
	my $sqlQuery = "SELECT name, site FROM restEnz";
	
	# Query the database
	my @allRES = DoQuery($sqlQuery);
	
	# Check that sequence was returned
	unless( @allRES ){
		return undef;
	}
	
	return @allRES;
}

###############################################################################################
#
# QuerySequence - Takes an accession number and returns the DNA sequence for it from the DB.
#
###############################################################################################
sub QuerySequence{
	
	# Store input accession numbers
	my ($accessionNo, $seqType) = @_;
	
	# Query to retireve the sequecne
	my $sqlQuery = "SELECT $seqType FROM gene WHERE accessionNo='$accessionNo'";
	
	# Run query and handle empty data
	my @seq = DoQuery($sqlQuery);
	unless( @seq ){
		return undef;
	}else{
		# Return sequence data
		return $seq[0][0];
	}
}

###########################################################################################################
#
# CalculateCodonUsage - Takes an array of codons and returns a hash with the percentage for each amino acid
#
##########################################################################################################
sub CalculateCodonUsage( @ ){

	my @codons = $_[0];
	
	#print Dumper(@codons);

	# Split out all individual codons in string to unique array entries.
	my @codonArray = split(/,/, $codons[0]->[0] );
	
	# Group condons into respective amino acid residues
	
	# Loop through array split out codon from number, create codon hash entry
	# and assign it the number
	my %codonHash;
	
	foreach my $codon (@codonArray){
	
		my @codonDetails = split(/:/, $codon);
		
		$codonHash{$codonDetails[0]} = $codonDetails[1];
	}
	
	# From this hash take the codon numbers needed for each residue.
	my %residueHash;
	
	my $percentCount = 0;
	my $codonTotalCount = 0;
	
	# Phenylalanine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UUU'} + $codonHash{'UUC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Phe'}{'UUU'} = $codonHash{'UUU'} * $percentCount;
		$residueHash{'Phe'}{'UUC'} = $codonHash{'UUC'} * $percentCount;
	}
	
	# Leucine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UUA'} + $codonHash{'UUG'} + $codonHash{'CUU'} + 
			$codonHash{'CUC'} + $codonHash{'CUA'} + $codonHash{'CUG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Leu'}{'UUA'} = $codonHash{'UUA'} * $percentCount;
		$residueHash{'Leu'}{'UUG'} = $codonHash{'UUG'} * $percentCount;
		$residueHash{'Leu'}{'CUU'} = $codonHash{'CUU'} * $percentCount;
		$residueHash{'Leu'}{'CUC'} = $codonHash{'CUC'} * $percentCount;
		$residueHash{'Leu'}{'CUA'} = $codonHash{'CUA'} * $percentCount;
		$residueHash{'Leu'}{'CUG'} = $codonHash{'CUG'} * $percentCount;
	}
	
	# Isoleucine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AUU'} + $codonHash{'AUC'} + $codonHash{'AUA'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Ile'}{'AUU'} = $codonHash{'AUU'} * $percentCount;
		$residueHash{'Ile'}{'AUC'} = $codonHash{'AUC'} * $percentCount;
		$residueHash{'Ile'}{'AUA'} = $codonHash{'AUA'} * $percentCount;
	}
	
	# Methionine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AUG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Met'}{'AUG'} = $codonHash{'AUG'} * $percentCount;
	}
	
	# Valine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GUU'} + $codonHash{'GUC'} + $codonHash{'GUA'} +
			$codonHash{'GUG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Val'}{'GUU'} = $codonHash{'GUU'} * $percentCount;
		$residueHash{'Val'}{'GUC'} = $codonHash{'GUC'} * $percentCount;
		$residueHash{'Val'}{'GUA'} = $codonHash{'GUA'} * $percentCount;
		$residueHash{'Val'}{'GUG'} = $codonHash{'GUG'} * $percentCount;
	}
	
	# Serine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UCU'} + $codonHash{'UCC'} + $codonHash{'UCA'} +
			$codonHash{'UCG'} + $codonHash{'AGU'} + $codonHash{'AGC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Ser'}{'UCU'} = $codonHash{'UCU'} * $percentCount;
		$residueHash{'Ser'}{'UCC'} = $codonHash{'UCC'} * $percentCount;
		$residueHash{'Ser'}{'UCA'} = $codonHash{'UCA'} * $percentCount;
		$residueHash{'Ser'}{'UCG'} = $codonHash{'UCG'} * $percentCount;
		$residueHash{'Ser'}{'AGU'} = $codonHash{'AGU'} * $percentCount;
		$residueHash{'Ser'}{'AGC'} = $codonHash{'AGC'} * $percentCount;
	}
	
	# Proline
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CCU'} + $codonHash{'CCC'} + $codonHash{'CCA'} +
			$codonHash{'CCG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Pro'}{'CCU'} = $codonHash{'CCU'} * $percentCount;
		$residueHash{'Pro'}{'CCC'} = $codonHash{'CCC'} * $percentCount;
		$residueHash{'Pro'}{'CCA'} = $codonHash{'CCA'} * $percentCount;
		$residueHash{'Pro'}{'CCG'} = $codonHash{'CCG'} * $percentCount;
	}
	
	# Threonine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'ACU'} + $codonHash{'ACC'} + $codonHash{'ACA'} +
			$codonHash{'ACG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Thr'}{'ACU'} = $codonHash{'ACU'} * $percentCount;
		$residueHash{'Thr'}{'ACC'} = $codonHash{'ACC'} * $percentCount;
		$residueHash{'Thr'}{'ACA'} = $codonHash{'ACA'} * $percentCount;
		$residueHash{'Thr'}{'ACG'} = $codonHash{'ACG'} * $percentCount;
	}
	
	# Alanine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GCU'} + $codonHash{'GCC'} + $codonHash{'GCA'} +
			$codonHash{'GCG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Ala'}{'GCU'} = $codonHash{'GCU'} * $percentCount;
		$residueHash{'Ala'}{'GCC'} = $codonHash{'GCC'} * $percentCount;
		$residueHash{'Ala'}{'GCA'} = $codonHash{'GCA'} * $percentCount;
		$residueHash{'Ala'}{'GCG'} = $codonHash{'GCG'} * $percentCount;
	}
	
	# Tyrosine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UAU'} + $codonHash{'UAC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Tyr'}{'UAU'} = $codonHash{'UAU'} * $percentCount;
		$residueHash{'Tyr'}{'UAC'} = $codonHash{'UAC'} * $percentCount;
	}
	
	# Histidine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CAU'} + $codonHash{'CAC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'His'}{'CAU'} = $codonHash{'CAU'} * $percentCount;
		$residueHash{'His'}{'CAC'} = $codonHash{'CAC'} * $percentCount;
	}
	
	# Aspergine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AAU'} + $codonHash{'AAC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Asn'}{'AAU'} = $codonHash{'AAU'} * $percentCount;
		$residueHash{'Asn'}{'AAC'} = $codonHash{'AAC'} * $percentCount;
	}
	
	# Lysine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AAA'} + $codonHash{'AAG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Lys'}{'AAA'} = $codonHash{'AAA'} * $percentCount;
		$residueHash{'Lys'}{'AAG'} = $codonHash{'AAG'} * $percentCount;
	}
	
	# Aspartic acid
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GAU'} + $codonHash{'GAC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Asp'}{'GAU'} = $codonHash{'GAU'} * $percentCount;
		$residueHash{'Asp'}{'GAC'} = $codonHash{'GAC'} * $percentCount;
	}
	
	# Glutamate
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GAA'} + $codonHash{'GAG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Glu'}{'GAA'} = $codonHash{'GAA'} * $percentCount;
		$residueHash{'Glu'}{'GAG'} = $codonHash{'GAG'} * $percentCount;
	}
	
	# Cysteine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UGU'} + $codonHash{'UGC'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Cys'}{'UGU'} = $codonHash{'UGU'} * $percentCount;
		$residueHash{'Cys'}{'UGC'} = $codonHash{'UGC'} * $percentCount;
	}
	
	# STOP
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UAA'} + $codonHash{'UAG'} + 
			$codonHash{'UGA'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Stop'}{'UAA'} = $codonHash{'UAA'} * $percentCount;
		$residueHash{'Stop'}{'UAG'} = $codonHash{'UAG'} * $percentCount;
		$residueHash{'Stop'}{'UGA'} = $codonHash{'UGA'} * $percentCount;
	}
	
	# Tryptophan
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UGG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Trp'}{'UGG'} = $codonHash{'UGG'} * $percentCount;
	}
	
	# Arginine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CGU'} + $codonHash{'CGC'} + $codonHash{'CGA'} +
			$codonHash{'CGG'} + $codonHash{'AGA'} + $codonHash{'AGG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Arg'}{'CGU'} = $codonHash{'CGU'} * $percentCount;
		$residueHash{'Arg'}{'CGC'} = $codonHash{'CGC'} * $percentCount;
		$residueHash{'Arg'}{'CGA'} = $codonHash{'CGA'} * $percentCount;
		$residueHash{'Arg'}{'CGG'} = $codonHash{'CGG'} * $percentCount;
		$residueHash{'Arg'}{'AGA'} = $codonHash{'AGA'} * $percentCount;
		$residueHash{'Arg'}{'AGG'} = $codonHash{'AGG'} * $percentCount;
	}
	
	# Glycine
	{
		$percentCount = 0;
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GGU'} + $codonHash{'GGC'} + $codonHash{'GGA'} +
			$codonHash{'GGG'};
	
		$percentCount = eval{ (100 / $codonTotalCount) };
	
		$residueHash{'Gly'}{'GGU'} = $codonHash{'GGU'} * $percentCount;
		$residueHash{'Gly'}{'GGC'} = $codonHash{'GGC'} * $percentCount;
		$residueHash{'Gly'}{'GGA'} = $codonHash{'GGA'} * $percentCount;
		$residueHash{'Gly'}{'GGG'} = $codonHash{'GGG'} * $percentCount;
	}
	 
	return %residueHash;
}

1;
