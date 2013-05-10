###########################################################################################################
#
#	ChromoDB.pm - All functions contained within this file comprise the complete middle-layer
#	Author: Sam Coulson
#
###########################################################################################################
package ChromoDB;

use strict;
use warnings;

use DBI;
use Data::Dumper;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(GetSearchResults DatabaseConnect GetIdentifier DoQuery QuerySearch IsArrayEmpty
	BuildCodingSeq GetCodons FindRES SetLastErrorMessage GetLastErrorMessage QuerySequence
	CalculateCodonUsage CalculateRatio CalculatePercent);

# Global variables

# global to store the last error
my $lastErrorMessage = '';

# CALLED FROM WEBSITE

##########################################################################################################
#
# GetSearchResults - Takes input string (search string), identifier(type i.e. gene, chromosome 
# location), and mode of search from the webpage and searches the database for matches. Returns hash
# of matches and extra info. or hash with error message
#
##########################################################################################################
sub GetSearchResults( $$$ ){
	
	# Get and store the input arguments
	my ($searchString, $idType, $browseMode) = @_;
	
	# Initialise hash for any error messages
	my %error = ();
	
	# Check for blank arguments passed in
	if(($searchString eq '') || ($idType eq '')){
		$error{'error'} = 'ERROR:ZERO_LENGTH_ARGUMENT';
		return %error;
	}
	
	# Convert requested identifier type to a database column name
	my $id = GetIdentifier($idType);
	# If id is undefinded pass back last error
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
	
		# Iterate over array, extracting and packaging the data in to the relevent hash key 
		for(my $i = 0; $i < @queryResult; $i++){
			# Name each key entry by accession number
			my $accessionNumber = $queryResult[$i]->[0];
			
			# Fill out the hash entry with all the data associated with the accessionNo query results
			$searchResults{$accessionNumber}{'GeneName'} = $queryResult[$i]->[1];
			$searchResults{$accessionNumber}{'ChromosomeLocation'} = $queryResult[$i]->[2];
			$searchResults{$accessionNumber}{'ProteinName'} = $queryResult[$i]->[3];
			$searchResults{$accessionNumber}{'ProteinId'} = $queryResult[$i]->[4];
			$searchResults{$accessionNumber}{'GeneLength'} = $queryResult[$i]->[5];
			
			# Retrieve coding sequence data for given accession number
			my @sequence = BuildCodingSeq($queryResult[$i]->[0]);
			# Check that data was returned.
			unless( @sequence ){
				# Set to N/A as it is not crucial
				$searchResults{$accessionNumber}{'SeqFeat'} = 'N/A'
			}else{
				# Copy array content to the hash to be sent back to caller
				$searchResults{$accessionNumber}{'SeqFeat'} = [@sequence];
			}
			
			# If browse mode is set to 2 then the user is probably looking at the individual data for the
			# gene in this case send back extra data for the accession number associated with the gene
			if( 2 == $browseMode ){
			
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
	
				# Retrieve codon usage data and package in to hash, no need to error set N/A as hash is already initialsed to 0 for each codon
				$searchResults{$accessionNumber}{'CodonUsage'} = {CalculateCodonUsage($queryResult[$i]->[0])};
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
	
	# Initialise hash for any errors
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
		# Assign name for hash key
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
# DatabaseConnect - Take no arguments and returns handle to database or undef.
# let the caller handle success and fail of connect.
#
##########################################################################################################
sub DatabaseConnect{
	
	#Defined the connection details to the database
	#my $dbname = 'scouls01'; 
	#my $user = 'scouls01';
	#my $password = 'iwr8sh8vb'; 
	#my $dbserver = 'localhost';
	
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
# GetIdentifier - Takes an indentifer form the website and returns an indentifer that complies with 
# the database column names.
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
# QuerySearch - Takes a search string, identifier type and browse mode, returns an array containing the 
# search results.
#
##########################################################################################################
sub QuerySearch( $$$ ){
	
	# Get the function parameters, assumes valid non-zero string and valid identifier input
	my ($searchString, $idType, $browseMode) = @_;
	
	# Initialise string for sql query
	my $sqlQuery = '';
	
	# If the search is in default mode, then find everything if associated with the 
	# search string.  If in broswe mode return everything that starts with the given letter.
	if( 0 == $browseMode || 2 == $browseMode){
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
# IsArrayEmpty - Takes an array as input and returns 0 if it is empty or 1 if not empty
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
# BuildCodingSeq - Takes an accession number and returns an array with all the introns and exons 
# in sequence.
#
###############################################################################################
sub BuildCodingSeq{

	# Get accession number for database lookup
	my $accessionNo = $_[0];
	
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuery = "SELECT featStart, featEnd FROM seqFeat WHERE accessionNo='$accessionNo'
	ORDER BY CAST(featStart AS SIGNED INTEGER) ASC";
	
	# Fetch the exon coding sequence information from database, array will progress as 
	# Type, start, stop then repeat for next item.
	my @tableRows = DoQuery($sqlQuery);
	unless( $tableRows[0]->[0] ){
		SetLastErrorMessage('ERROR:DB_COLUMN_EMPTY');
		return undef;
	}
	
	# Get the length of the sequence
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuerySeqlength = "SELECT geneSeqLen FROM gene WHERE accessionNo='$accessionNo'";
	
	# Run the query
	my @sequenceLength = DoQuery($sqlQuerySeqlength);
	unless( $sequenceLength[0]->[0] ){
		SetLastErrorMessage('ERROR:DB_COLUMN_EMPTY');
		return undef;
	}

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
# GetCodons - Takes an accession number for a gene and returns a hash of codons with frequency value for 
# each one from the database
#
##########################################################################################################
sub GetCodons( $ ){

	# Grab the accesion number for the genes codons we want
	my $accessionNo = $_[0];
	
	# Prepare and initialise all hash elements for all 64 possible codons
	# this will store the values for each codon from codonArray.
	my %codonHash = ();
	
	$codonHash{'UUU'} = 0; #1
	$codonHash{'UUC'} = 0; #2
	$codonHash{'UUA'} = 0; #3
	$codonHash{'UUG'} = 0; #4
	$codonHash{'CUU'} = 0; #5
	$codonHash{'CUC'} = 0; #6
	$codonHash{'CUA'} = 0; #7
	$codonHash{'CUG'} = 0; #8
	$codonHash{'AUU'} = 0; #9
	$codonHash{'AUC'} = 0; #10
	$codonHash{'AUA'} = 0; #11
	$codonHash{'AUG'} = 0; #12
	$codonHash{'GUU'} = 0; #13
	$codonHash{'GUC'} = 0; #14
	$codonHash{'GUA'} = 0; #15
	$codonHash{'GUG'} = 0; #16
	
	$codonHash{'UCU'} = 0; #17
	$codonHash{'UCC'} = 0; #18
	$codonHash{'UCA'} = 0; #19
	$codonHash{'UCG'} = 0; #20
	
	$codonHash{'AGU'} = 0; #21
	$codonHash{'AGC'} = 0; #22
	
	$codonHash{'CCU'} = 0; #23
	$codonHash{'CCC'} = 0; #24
	$codonHash{'CCA'} = 0; #25
	$codonHash{'CCG'} = 0; #26
	
	$codonHash{'ACU'} = 0; #27
	$codonHash{'ACC'} = 0; #28
	$codonHash{'ACA'} = 0; #29
	$codonHash{'ACG'} = 0; #30
	
	$codonHash{'GCU'} = 0; #31
	$codonHash{'GCC'} = 0; #32
	$codonHash{'GCA'} = 0; #33
	$codonHash{'GCG'} = 0; #34
	
	$codonHash{'UAU'} = 0; #35
	$codonHash{'UAC'} = 0; #36
	
	$codonHash{'CAU'} = 0; #37
	$codonHash{'CAC'} = 0; #38
	
	$codonHash{'AAU'} = 0; #39
	$codonHash{'AAC'} = 0; #40
	$codonHash{'AAA'} = 0; #41
	$codonHash{'AAG'} = 0; #42
	
	$codonHash{'GAU'} = 0; #43
	$codonHash{'GAC'} = 0; #44
	
	$codonHash{'GAA'} = 0; #45
	$codonHash{'GAG'} = 0; #46
	
	$codonHash{'UGU'} = 0; #47
	$codonHash{'UGC'} = 0; #48
	
	$codonHash{'UAA'} = 0; #49
	$codonHash{'UAG'} = 0; #50
	$codonHash{'UGA'} = 0; #51
	
	$codonHash{'UGG'} = 0; #52
	
	$codonHash{'CGU'} = 0; #53
	$codonHash{'CGC'} = 0; #54
	$codonHash{'CGA'} = 0; #55
	$codonHash{'CGG'} = 0; #56
	
	$codonHash{'AGA'} = 0; #57
	$codonHash{'AGG'} = 0; #58
	
	$codonHash{'GGU'} = 0; #59
	$codonHash{'GGC'} = 0; #60
	$codonHash{'GGA'} = 0; #61
	$codonHash{'GGG'} = 0; #62
	
	$codonHash{'CAA'} = 0; #63
	$codonHash{'CAG'} = 0; #64
	
	
	# Query for codons given the accession number
	my $sqlQuery = "SELECT codonCount FROM codonBias WHERE accessionNo = '$accessionNo'";
	
	# Run the query and save the result in a array
	my @accessionCodons = DoQuery($sqlQuery);
	
	unless( $accessionCodons[0]->[0] ){
		# Return hash with error key to indicate no codons 
		my %errorHash;
		$errorHash{'error'} = '';
		return %errorHash;
	}	
	
	# In the DB condons for all entries are just one long comma separated string so
	# split out all individual codons in string to unique array entries.
	my @codonArray = split(/,/, $accessionCodons[0]->[0] );
	
	# Search and replace any T's with U's, as the DB has codons stored as using Thymine.
	foreach my $codonEntry (@codonArray){
		$codonEntry =~ s/T/U/g;
	}
	
	# Loop through array split out 3 letter codon from number, assign number to codon 
	# respective hash entry above 
	foreach my $codon (@codonArray){
	
		my @codonDetails = split(/:/, $codon);
		
		# Make sure the triplet is one of the triplets defined in condonHash
		# this should prevent incorrect or invalid triplets getting in to the hash
		if( exists $codonHash{$codonDetails[0]} )
		{
			# Assign triplet to cpdon name as key and frequency as it's value
			$codonHash{$codonDetails[0]} = $codonDetails[1];
		}
	}
	
	return %codonHash;
}

##########################################################################################################
#
# GetlastErrorMessage - Takes no arguments and returns the last error set in the global variable
#
##########################################################################################################
sub GetLastErrorMessage{
	return $lastErrorMessage;
}

##########################################################################################################
#
# SetLastErrorMessage - Takes an error string contining a message and set the global error message variable 
# to this
#
##########################################################################################################
sub SetLastErrorMessage( $ ){
	if( $_[0] )
	{
		# Set the global variable to caller defined error message.
		$lastErrorMessage = $_[0];
	}else{
		# Caller passed nothing as the message so set it to undefined.
		$lastErrorMessage = $_[0] = 'ERROR_UNDEFINED';
	}
}

###############################################################################################
#
# FindRES -  Returns a list RES (names and cut sites) in the database.  
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
	my $sqlQuery = "SELECT $seqType, complement FROM gene WHERE accessionNo='$accessionNo'";
	
	# Run query and handle empty data
	my @seq = DoQuery($sqlQuery);
	
	unless( $seq[0]->[0] ){
		return undef;
	}else{
		#If the sequence is a compliment then it needs to be converted back to a 5 prime sequence.
		if( $seq[0][1] eq 'C'){
			$seq[0][0] =~ tr/ATCG/TAGC/;
		} 
		
		# Return sequence data
		return $seq[0][0];
	}
}

###############################################################################################
#
# CalculateRatio - Takes the total number of codons and frequency for each codons and returns 
# the usage ratio for the specific amino acid residue  
#
###############################################################################################
sub CalculateRatio($$){
	my($numerator, $denominator) = @_;
	
	# If there are no codons involved then return 0 to ensure that the codon is not set to 
	# undef or a divide by 0 happens.
	if(0 == $denominator){
		return 0;
	}
	
	# Calculate the percentage.
	# Rounding part of this calculation taken from 'hossman' at http://www.perlmonks.org/?node_id=1873
	my $percent = sprintf "%.2f", $numerator / $denominator; 
	
	# Return the rounded result. 
	return $percent;
}

###############################################################################################
#
# CalculatePercent - Takes the total number of codons in the chromosome and frequency for a  
# codon and returns the usage percentage over for the whole chromosome
#
###############################################################################################
sub CalculatePercent($$){
	my($numerator, $denominator) = @_;
	
	# If there are no codons involved then return 0 to ensure that the codon is not set to 
	# undef or a divide by 0 happens.
	if(0 == $denominator){
		return 0;
	}
	
	# Calculate the percentage.
	# Rounding part of this calculation taken from 'hossman' at http://www.perlmonks.org/?node_id=1873 
	my $percent = sprintf "%.2f", ($numerator / $denominator) * 100;
	
	# Return the rounded result. 
	return $percent;
}

###########################################################################################################
#
# CalculateCodonUsage - Takes an accession number and returns a hash with the ratio's for each amino acid 
# and the percetange for each codon across the whole chromosome.
#
##########################################################################################################
sub CalculateCodonUsage( $ ){

	# Expects an accession number
	my $accessionNo = $_[0];

	my %error = ();
	
	# Hash to store all the amino acid residue ratios and percentages in a
	# two element array, function will return this when finished.
	my %residueHash = ();

	# Retrieve the codons for the given accession number
	my %codonHash = GetCodons( $accessionNo );
	
	# Check to see if an error hash has been returned and pass back 'N/A' indicating no codon data
	if( exists($codonHash{'error'}) ){
		$residueHash{'error'}{'error'}[0] = 'N/A';
		$residueHash{'error'}{'error'}[1] = 'N/A';
		# Return empty hash initialised to 0 as caller function expects a hash
		return %residueHash; 
	}
	
	# Retrieve the codons for the whole chromosome
	my %chromoCodonHash = GetCodons( 'Chrom_12' );
	
	# Check to see if an error hash has been returned and pass back 'N/A' indicating no codon data
	if( exists($codonHash{'error'}) ){
		$residueHash{'error'}{'error'}[0] = 'N/A';
		$residueHash{'error'}{'error'}[1] = 'N/A';
		# Return empty hash initialised to 0 as caller function expects a hash
		return %residueHash; 
	}
	
	# Variable to save the total nnumber of codons in the chromosome, this is used for calculating percentages
	# for codon usages over the whole chromosome.
	my $chromoCodonTotal = 0;
	
	# Iterate over the hash for the codons and add up all their counts 
	while( my($key, $value) = each(%chromoCodonHash) ){
		$chromoCodonTotal += $value;
	}
	
	# For all codons in codonHash group into amino acids and calculate the ratio
	# for each codon to represent the codon usage for each amino acid.
	
	# Initialise variable for keeping track of the total numebr of condons per residue
	# this gets reset each time an amino acid codon usage is calculated.
	my $codonTotalCount = 0;
	
	# Phenylalanine
	{
		$codonTotalCount = 0;
		# Get the total number of codons that make up the amino acid
		$codonTotalCount = $codonHash{'UUU'} + $codonHash{'UUC'};
		
		# Assign the usage ratio to each codon using the CalculateRatio function
		$residueHash{'Phe'}{'UUU'}[0] = CalculateRatio($codonHash{'UUU'}, $codonTotalCount);
		$residueHash{'Phe'}{'UUC'}[0] = CalculateRatio($codonHash{'UUC'}, $codonTotalCount);
		
		# Assign the percentage usage over the whole chromosome to each codon using the CalculatePercent function
		$residueHash{'Phe'}{'UUU'}[1] = CalculatePercent($chromoCodonHash{'UUU'}, $chromoCodonTotal);
		$residueHash{'Phe'}{'UUC'}[1] = CalculatePercent($chromoCodonHash{'UUC'}, $chromoCodonTotal);
	}
	
	# Repeat above for every amino acids using their own codons.
	
	# Leucine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UUA'} + $codonHash{'UUG'} + $codonHash{'CUU'} + 
			$codonHash{'CUC'} + $codonHash{'CUA'} + $codonHash{'CUG'};
	
		$residueHash{'Leu'}{'UUA'}[0] = CalculateRatio($codonHash{'UUA'}, $codonTotalCount);
		$residueHash{'Leu'}{'UUG'}[0] = CalculateRatio($codonHash{'UUG'}, $codonTotalCount);
		$residueHash{'Leu'}{'CUU'}[0] = CalculateRatio($codonHash{'CUU'}, $codonTotalCount);
		$residueHash{'Leu'}{'CUC'}[0] = CalculateRatio($codonHash{'CUC'}, $codonTotalCount);
		$residueHash{'Leu'}{'CUA'}[0] = CalculateRatio($codonHash{'CUA'}, $codonTotalCount);
		$residueHash{'Leu'}{'CUG'}[0] = CalculateRatio($codonHash{'CUG'}, $codonTotalCount);
		
		$residueHash{'Leu'}{'UUA'}[1] = CalculatePercent($chromoCodonHash{'UUA'}, $chromoCodonTotal);
		$residueHash{'Leu'}{'UUG'}[1] = CalculatePercent($chromoCodonHash{'UUG'}, $chromoCodonTotal);
		$residueHash{'Leu'}{'CUU'}[1] = CalculatePercent($chromoCodonHash{'CUU'}, $chromoCodonTotal);
		$residueHash{'Leu'}{'CUC'}[1] = CalculatePercent($chromoCodonHash{'CUC'}, $chromoCodonTotal);
		$residueHash{'Leu'}{'CUA'}[1] = CalculatePercent($chromoCodonHash{'CUA'}, $chromoCodonTotal);
		$residueHash{'Leu'}{'CUG'}[1] = CalculatePercent($chromoCodonHash{'CUG'}, $chromoCodonTotal);
	}
	
	# Isoleucine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AUU'} + $codonHash{'AUC'} + $codonHash{'AUA'};
	
		$residueHash{'Ile'}{'AUU'}[0] = CalculateRatio($codonHash{'AUU'}, $codonTotalCount);
		$residueHash{'Ile'}{'AUC'}[0] = CalculateRatio($codonHash{'AUC'}, $codonTotalCount);
		$residueHash{'Ile'}{'AUA'}[0] = CalculateRatio($codonHash{'AUA'}, $codonTotalCount);
		
		$residueHash{'Ile'}{'AUU'}[1] = CalculatePercent($chromoCodonHash{'AUU'}, $chromoCodonTotal);
		$residueHash{'Ile'}{'AUC'}[1] = CalculatePercent($chromoCodonHash{'AUC'}, $chromoCodonTotal);
		$residueHash{'Ile'}{'AUA'}[1] = CalculatePercent($chromoCodonHash{'AUA'}, $chromoCodonTotal);
	}
	
	# Methionine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AUG'};
	
		$residueHash{'Met'}{'AUG'}[0] = CalculateRatio($codonHash{'AUG'}, $codonTotalCount);
		
		$residueHash{'Met'}{'AUG'}[1] = CalculatePercent($chromoCodonHash{'AUG'}, $chromoCodonTotal);
	}
	
	# Valine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GUU'} + $codonHash{'GUC'} + $codonHash{'GUA'} +
			$codonHash{'GUG'};
	
		$residueHash{'Val'}{'GUU'}[0] = CalculateRatio($codonHash{'GUU'}, $codonTotalCount);
		$residueHash{'Val'}{'GUC'}[0] = CalculateRatio($codonHash{'GUC'}, $codonTotalCount);
		$residueHash{'Val'}{'GUA'}[0] = CalculateRatio($codonHash{'GUA'}, $codonTotalCount);
		$residueHash{'Val'}{'GUG'}[0] = CalculateRatio($codonHash{'GUG'}, $codonTotalCount);
		
		$residueHash{'Val'}{'GUU'}[1] = CalculatePercent($chromoCodonHash{'GUU'}, $chromoCodonTotal);
		$residueHash{'Val'}{'GUC'}[1] = CalculatePercent($chromoCodonHash{'GUC'}, $chromoCodonTotal);
		$residueHash{'Val'}{'GUA'}[1] = CalculatePercent($chromoCodonHash{'GUA'}, $chromoCodonTotal);
		$residueHash{'Val'}{'GUG'}[1] = CalculatePercent($chromoCodonHash{'GUG'}, $chromoCodonTotal);
	}
	
	# Serine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UCU'} + $codonHash{'UCC'} + $codonHash{'UCA'} +
			$codonHash{'UCG'} + $codonHash{'AGU'} + $codonHash{'AGC'};
	
		$residueHash{'Ser'}{'UCU'}[0] = CalculateRatio($codonHash{'UCU'}, $codonTotalCount);
		$residueHash{'Ser'}{'UCC'}[0] = CalculateRatio($codonHash{'UCC'}, $codonTotalCount);
		$residueHash{'Ser'}{'UCA'}[0] = CalculateRatio($codonHash{'UCA'}, $codonTotalCount);
		$residueHash{'Ser'}{'UCG'}[0] = CalculateRatio($codonHash{'UCG'}, $codonTotalCount);
		$residueHash{'Ser'}{'AGU'}[0] = CalculateRatio($codonHash{'AGU'}, $codonTotalCount);
		$residueHash{'Ser'}{'AGC'}[0] = CalculateRatio($codonHash{'AGC'}, $codonTotalCount);
		
		$residueHash{'Ser'}{'UCU'}[1] = CalculatePercent($chromoCodonHash{'UCU'}, $chromoCodonTotal);
		$residueHash{'Ser'}{'UCC'}[1] = CalculatePercent($chromoCodonHash{'UCC'}, $chromoCodonTotal);
		$residueHash{'Ser'}{'UCA'}[1] = CalculatePercent($chromoCodonHash{'UCA'}, $chromoCodonTotal);
		$residueHash{'Ser'}{'UCG'}[1] = CalculatePercent($chromoCodonHash{'UCG'}, $chromoCodonTotal);
		$residueHash{'Ser'}{'AGU'}[1] = CalculatePercent($chromoCodonHash{'AGU'}, $chromoCodonTotal);
		$residueHash{'Ser'}{'AGC'}[1] = CalculatePercent($chromoCodonHash{'AGC'}, $chromoCodonTotal);
	}
	
	# Proline
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CCU'} + $codonHash{'CCC'} + $codonHash{'CCA'} +
			$codonHash{'CCG'};
	
		$residueHash{'Pro'}{'CCU'}[0] = CalculateRatio($codonHash{'CCU'}, $codonTotalCount);
		$residueHash{'Pro'}{'CCC'}[0] = CalculateRatio($codonHash{'CCC'}, $codonTotalCount);
		$residueHash{'Pro'}{'CCA'}[0] = CalculateRatio($codonHash{'CCA'}, $codonTotalCount);
		$residueHash{'Pro'}{'CCG'}[0] = CalculateRatio($codonHash{'CCG'}, $codonTotalCount);
		
		$residueHash{'Pro'}{'CCU'}[1] = CalculatePercent($chromoCodonHash{'CCU'}, $chromoCodonTotal);
		$residueHash{'Pro'}{'CCC'}[1] = CalculatePercent($chromoCodonHash{'CCC'}, $chromoCodonTotal);
		$residueHash{'Pro'}{'CCA'}[1] = CalculatePercent($chromoCodonHash{'CCA'}, $chromoCodonTotal);
		$residueHash{'Pro'}{'CCG'}[1] = CalculatePercent($chromoCodonHash{'CCG'}, $chromoCodonTotal);
	}
	
	# Threonine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'ACU'} + $codonHash{'ACC'} + $codonHash{'ACA'} +
			$codonHash{'ACG'};
	
		$residueHash{'Thr'}{'ACU'}[0] = CalculateRatio($codonHash{'ACU'}, $codonTotalCount);
		$residueHash{'Thr'}{'ACC'}[0] = CalculateRatio($codonHash{'ACC'}, $codonTotalCount);
		$residueHash{'Thr'}{'ACA'}[0] = CalculateRatio($codonHash{'ACA'}, $codonTotalCount);
		$residueHash{'Thr'}{'ACG'}[0] = CalculateRatio($codonHash{'ACG'}, $codonTotalCount);
		
		$residueHash{'Thr'}{'ACU'}[1] = CalculatePercent($chromoCodonHash{'ACU'}, $chromoCodonTotal);
		$residueHash{'Thr'}{'ACC'}[1] = CalculatePercent($chromoCodonHash{'ACC'}, $chromoCodonTotal);
		$residueHash{'Thr'}{'ACA'}[1] = CalculatePercent($chromoCodonHash{'ACA'}, $chromoCodonTotal);
		$residueHash{'Thr'}{'ACG'}[1] = CalculatePercent($chromoCodonHash{'ACG'}, $chromoCodonTotal);
	}
	
	# Alanine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GCU'} + $codonHash{'GCC'} + $codonHash{'GCA'} +
			$codonHash{'GCG'};
	
		$residueHash{'Ala'}{'GCU'}[0] = CalculateRatio($codonHash{'GCU'}, $codonTotalCount);
		$residueHash{'Ala'}{'GCC'}[0] = CalculateRatio($codonHash{'GCC'}, $codonTotalCount);
		$residueHash{'Ala'}{'GCA'}[0] = CalculateRatio($codonHash{'GCA'}, $codonTotalCount);
		$residueHash{'Ala'}{'GCG'}[0] = CalculateRatio($codonHash{'GCG'}, $codonTotalCount);
		
		$residueHash{'Ala'}{'GCU'}[1] = CalculatePercent($chromoCodonHash{'GCU'}, $chromoCodonTotal);
		$residueHash{'Ala'}{'GCC'}[1] = CalculatePercent($chromoCodonHash{'GCC'}, $chromoCodonTotal);
		$residueHash{'Ala'}{'GCA'}[1] = CalculatePercent($chromoCodonHash{'GCA'}, $chromoCodonTotal);
		$residueHash{'Ala'}{'GCG'}[1] = CalculatePercent($chromoCodonHash{'GCG'}, $chromoCodonTotal);
	}
	
	# Tyrosine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UAU'} + $codonHash{'UAC'};
	
		$residueHash{'Tyr'}{'UAU'}[0] = CalculateRatio($codonHash{'UAU'}, $codonTotalCount);
		$residueHash{'Tyr'}{'UAC'}[0] = CalculateRatio($codonHash{'UAC'}, $codonTotalCount);
		
		$residueHash{'Tyr'}{'UAU'}[1] = CalculatePercent($chromoCodonHash{'UAU'}, $chromoCodonTotal);
		$residueHash{'Tyr'}{'UAC'}[1] = CalculatePercent($chromoCodonHash{'UAC'}, $chromoCodonTotal);
	}
	
	# Histidine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CAU'} + $codonHash{'CAC'};
	
		$residueHash{'His'}{'CAU'}[0] = CalculateRatio($codonHash{'CAU'}, $codonTotalCount);
		$residueHash{'His'}{'CAC'}[0] = CalculateRatio($codonHash{'CAC'}, $codonTotalCount);
		
		$residueHash{'His'}{'CAU'}[1] = CalculatePercent($chromoCodonHash{'CAU'}, $chromoCodonTotal);
		$residueHash{'His'}{'CAC'}[1] = CalculatePercent($chromoCodonHash{'CAC'}, $chromoCodonTotal);
	}
	
	# Glutamine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CAA'} + $codonHash{'CAG'};
		
		$residueHash{'Gln'}{'CAA'}[0] = CalculateRatio($codonHash{'CAA'}, $codonTotalCount);
		$residueHash{'Gln'}{'CAG'}[0] = CalculateRatio($codonHash{'CAG'}, $codonTotalCount);
		
		$residueHash{'Gln'}{'CAA'}[1] = CalculatePercent($chromoCodonHash{'CAA'}, $chromoCodonTotal);
		$residueHash{'Gln'}{'CAG'}[1] = CalculatePercent($chromoCodonHash{'CAG'}, $chromoCodonTotal);
	}
	
	# Aspergine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AAU'} + $codonHash{'AAC'};
	
		$residueHash{'Asn'}{'AAU'}[0] = CalculateRatio($codonHash{'AAU'}, $codonTotalCount);
		$residueHash{'Asn'}{'AAC'}[0] = CalculateRatio($codonHash{'AAC'}, $codonTotalCount);
		
		$residueHash{'Asn'}{'AAU'}[1] = CalculatePercent($chromoCodonHash{'AAU'}, $chromoCodonTotal);
		$residueHash{'Asn'}{'AAC'}[1] = CalculatePercent($chromoCodonHash{'AAC'}, $chromoCodonTotal);
	}
	
	# Lysine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'AAA'} + $codonHash{'AAG'};
	
		$residueHash{'Lys'}{'AAA'}[0] = CalculateRatio($codonHash{'AAA'}, $codonTotalCount);
		$residueHash{'Lys'}{'AAG'}[0] = CalculateRatio($codonHash{'AAG'}, $codonTotalCount);
		
		$residueHash{'Lys'}{'AAA'}[1] = CalculatePercent($chromoCodonHash{'AAA'}, $chromoCodonTotal);
		$residueHash{'Lys'}{'AAG'}[1] = CalculatePercent($chromoCodonHash{'AAG'}, $chromoCodonTotal);
	}
	
	# Aspartic acid
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GAU'} + $codonHash{'GAC'};
	
		$residueHash{'Asp'}{'GAU'}[0] = CalculateRatio($codonHash{'GAU'}, $codonTotalCount);
		$residueHash{'Asp'}{'GAC'}[0] = CalculateRatio($codonHash{'GAC'}, $codonTotalCount);
		
		$residueHash{'Asp'}{'GAU'}[1] = CalculatePercent($chromoCodonHash{'GAU'}, $chromoCodonTotal);
		$residueHash{'Asp'}{'GAC'}[1] = CalculatePercent($chromoCodonHash{'GAC'}, $chromoCodonTotal);
	}
	
	# Glutamate
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GAA'} + $codonHash{'GAG'};
	
		$residueHash{'Glu'}{'GAA'}[0] = CalculateRatio($codonHash{'GAA'}, $codonTotalCount);
		$residueHash{'Glu'}{'GAG'}[0] = CalculateRatio($codonHash{'GAG'}, $codonTotalCount);
		
		$residueHash{'Glu'}{'GAA'}[1] = CalculatePercent($chromoCodonHash{'GAA'}, $chromoCodonTotal);
		$residueHash{'Glu'}{'GAG'}[1] = CalculatePercent($chromoCodonHash{'GAG'}, $chromoCodonTotal);
	}
	
	# Cysteine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UGU'} + $codonHash{'UGC'};
	
		$residueHash{'Cys'}{'UGU'}[0] = CalculateRatio($codonHash{'UGU'}, $codonTotalCount);
		$residueHash{'Cys'}{'UGC'}[0] = CalculateRatio($codonHash{'UGC'}, $codonTotalCount);
		
		$residueHash{'Cys'}{'UGU'}[1] = CalculatePercent($chromoCodonHash{'UGU'}, $chromoCodonTotal);
		$residueHash{'Cys'}{'UGC'}[1] = CalculatePercent($chromoCodonHash{'UGC'}, $chromoCodonTotal);
	}
	
	# STOP
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UAA'} + $codonHash{'UAG'} + $codonHash{'UGA'};
	
		$residueHash{'Stop'}{'UAA'}[0] = CalculateRatio($codonHash{'UAA'}, $codonTotalCount);
		$residueHash{'Stop'}{'UAG'}[0] = CalculateRatio($codonHash{'UAG'}, $codonTotalCount);
		$residueHash{'Stop'}{'UGA'}[0] = CalculateRatio($codonHash{'UGA'}, $codonTotalCount);
		
		$residueHash{'Stop'}{'UAA'}[1] = CalculatePercent($chromoCodonHash{'UAA'}, $chromoCodonTotal);
		$residueHash{'Stop'}{'UAG'}[1] = CalculatePercent($chromoCodonHash{'UAG'}, $chromoCodonTotal);
		$residueHash{'Stop'}{'UGA'}[1] = CalculatePercent($chromoCodonHash{'UGA'}, $chromoCodonTotal);
	}
	
	# Tryptophan
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'UGG'};
	
		$residueHash{'Trp'}{'UGG'}[0] = CalculateRatio($codonHash{'UGG'}, $codonTotalCount);
		
		$residueHash{'Trp'}{'UGG'}[1] = CalculatePercent($chromoCodonHash{'UGG'}, $chromoCodonTotal);
	}
	
	# Arginine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'CGU'} + $codonHash{'CGC'} + $codonHash{'CGA'} +
			$codonHash{'CGG'} + $codonHash{'AGA'} + $codonHash{'AGG'};
	
		$residueHash{'Arg'}{'CGU'}[0] = CalculateRatio($codonHash{'CGU'}, $codonTotalCount);
		$residueHash{'Arg'}{'CGC'}[0] = CalculateRatio($codonHash{'CGC'}, $codonTotalCount);
		$residueHash{'Arg'}{'CGA'}[0] = CalculateRatio($codonHash{'CGA'}, $codonTotalCount);
		$residueHash{'Arg'}{'CGG'}[0] = CalculateRatio($codonHash{'CGG'}, $codonTotalCount);
		$residueHash{'Arg'}{'AGA'}[0] = CalculateRatio($codonHash{'AGA'}, $codonTotalCount);
		$residueHash{'Arg'}{'AGG'}[0] = CalculateRatio($codonHash{'AGG'}, $codonTotalCount);
		
		$residueHash{'Arg'}{'CGU'}[1] = CalculatePercent($chromoCodonHash{'CGU'}, $chromoCodonTotal);
		$residueHash{'Arg'}{'CGC'}[1] = CalculatePercent($chromoCodonHash{'CGC'}, $chromoCodonTotal);
		$residueHash{'Arg'}{'CGA'}[1] = CalculatePercent($chromoCodonHash{'CGA'}, $chromoCodonTotal);
		$residueHash{'Arg'}{'CGG'}[1] = CalculatePercent($chromoCodonHash{'CGG'}, $chromoCodonTotal);
		$residueHash{'Arg'}{'AGA'}[1] = CalculatePercent($chromoCodonHash{'AGA'}, $chromoCodonTotal);
		$residueHash{'Arg'}{'AGG'}[1] = CalculatePercent($chromoCodonHash{'AGG'}, $chromoCodonTotal);
	}
	
	# Glycine
	{
		$codonTotalCount = 0;
	
		$codonTotalCount = $codonHash{'GGU'} + $codonHash{'GGC'} + $codonHash{'GGA'} +
			$codonHash{'GGG'};
	
		$residueHash{'Gly'}{'GGU'}[0] = CalculateRatio($codonHash{'GGU'}, $codonTotalCount );
		$residueHash{'Gly'}{'GGC'}[0] = CalculateRatio($codonHash{'GGC'}, $codonTotalCount );
		$residueHash{'Gly'}{'GGA'}[0] = CalculateRatio($codonHash{'GGA'}, $codonTotalCount );
		$residueHash{'Gly'}{'GGG'}[0] = CalculateRatio($codonHash{'GGG'}, $codonTotalCount );
		
		$residueHash{'Gly'}{'GGU'}[1] = CalculatePercent($chromoCodonHash{'GGU'}, $chromoCodonTotal);
		$residueHash{'Gly'}{'GGC'}[1] = CalculatePercent($chromoCodonHash{'GGC'}, $chromoCodonTotal);
		$residueHash{'Gly'}{'GGA'}[1] = CalculatePercent($chromoCodonHash{'GGA'}, $chromoCodonTotal);
		$residueHash{'Gly'}{'GGG'}[1] = CalculatePercent($chromoCodonHash{'GGG'}, $chromoCodonTotal);
	}
	
	# Return the filled out hash containing the amino acid residues back to caller.
	return %residueHash;
}

1;
