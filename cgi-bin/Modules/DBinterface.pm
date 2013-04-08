package DBinterface;
use DBI; 
use Data::Dumper;
# Subroutines

# Database facing

##########################################################################################################
#
# DoQuery - Takes a MySQL search string, returns the result from the query in an array
#
##########################################################################################################
sub DoQuery( $ ){

	# Get query string from function argument
	my $sqlQuery = $_[0];
	
	# Attempt to connect to database 
	my $hDb = DBinterface::databaseConnect();
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
		if( isArrayEmpty( @rowData ) eq 0 ){
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
# getIdentifier - Takes an indentifer and returns an indentifer that complies with the DB column names.
#
##########################################################################################################
sub getIdentifier{
	
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
# querySearch - Takes a search string and type, returns comma separated list of search results
#
##########################################################################################################
sub querySearch{
	
	# Get the function parameters, assumes valid non-zero string and valid identifier input
	my ($searchString, $idType) = @_;
	
	# Run search query **$searchstring must be in quotes***
	my $sqlQuery = "SELECT accessionNo, geneId, chromLoc, proteinName, ProteinId, geneSeqLen FROM gene WHERE $idType='$searchString'";
	
	# Run query
	my @searchResults = DBinterface::DoQuery($sqlQuery);
	
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
# queryColumn - Takes a column id and returns elements of a single column
#
##########################################################################################################
sub QueryColumn{

	# Assumes the identifer passed will be in the correct form as this should only every be called from code
	# so no need to check it.
	
	my $columnId = $_[0];
	
	# Define query for specified colum
	my $sqlQuery = "SELECT accessionNo, $columnId FROM gene";
	
	# Run query
	my @columnData = DBinterface::DoQuery($sqlQuery);
	
	# If there is no data in array return error andlet caller get the reason
	unless( @columnData ){
		return undef;
	}else{	
		return @columnData;
	}
}
###############################################################################################
#
# querySequence - Takes an accession number and returns the DNA sequence for it from the DB.
#
###############################################################################################
sub querySequence{
	
	# Store input accession numbers
	my ($accessionNo, $seqType) = @_;
	
	# Query to retireve the sequecne
	my $sqlQuery = "SELECT $seqType FROM gene WHERE accessionNo='$accessionNo'";
	
	# Run query and handle empty data
	my @seq = DBinterface::DoQuery($sqlQuery);
	unless( @seq ){
		return undef;
	}else{
		# Return sequence data
		return $seq[0][0];
	}
}


# findRES - Takes a RES name and an Id and returns a list of matches within the given identifer sequence.
sub findRES( $ $ ){
	return 1;
}

# addRES - Takes a DNA sequecne and a name for the restriction enzyme. Returns 1 on success 
# (has been added) or 0 on fail (cannot be added)
sub addRES( $$ ){
	return 1;
}

###############################################################################################
#
# buildCodingSeq - Takes an Id and returns an array with all the introns and exons in sequence.
#
###############################################################################################
sub buildCodingSeq{

	# Get accession number for DB lookup
	my $accessionNo = $_[0];
	
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuery = "SELECT featStart, featEnd FROM seqFeat WHERE accessionNo='$accessionNo'
	ORDER BY LENGTH(featStart)";
	
	# Fetch the exon coding sequence information from DB, array will progress as 
	# Type, start, stop then repeat for next item.
	my @tableRows = DBinterface::DoQuery($sqlQuery);
	unless( @tableRows ){
		SetLastErrorMessage('ERROR:DB_COLUMN_EMPTY');
		return undef;
	}
	
	# Get the length of the sequence
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuerySeqlength = "SELECT geneSeqLen FROM gene WHERE accessionNo='$accessionNo'";
	
	
	my @sequenceLength = DBinterface::DoQuery($sqlQuerySeqlength);
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
		# Get first and second numbers of first entry and fomrat them into a string
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
		# If no then infer an intron and calculate intron length, sequence begins with intron.
		my $entry = join("","NCS;","0",":",$tableRows[0][0]-1);
		push(@CDSarray, $entry);
	}
	
	# Extract start and end positions of the exons, put them into array.
	for( my $i = $tableRowIndex; $i < scalar(@tableRows); $i++){
		
		my ($segStart, $segStop); 
		
		# Get start number of current exon
		$segStart = $tableRows[$i][0];
		
		# Extract stop position of exon 
		$segStop = $tableRows[$i][1];
		
		# Write the start/stop information into the string
		my $entry = join("","EXON;",$segStart,":",$segStop);
		push(@CDSarray, $entry);
	
		# Find distance between current exon and next and denote as NCS in array.
		if( defined($tableRows[$i+1]) )
		{
			my $ncsEntry = join("","NCS;",$tableRows[$i][1]+1,":",$tableRows[$i+1][0]-1);
			push(@CDSarray, $ncsEntry);
		}else{
			my $ncsEntry = join("","NCS;",$segStop+1,":",$sequenceLength[0][0]);
			push(@CDSarray, $ncsEntry);
		}
	}
	
	return @CDSarray;
}

sub BuildSummaryData( $ ){

	# ASSUMPTION: identifer used for search is passed in i.e AccessionNumber or GeneName etc. 
	# Get and store the input arguments 
	my $accessionNo = $_[0];
	
	# Function should never be called with blank argument as it will be called when the user select from search
	# or browse list.
	
	my $sqlQuery = "SELECT geneId, chromLoc, proteinName, geneSeq, proteinSeq FROM gene WHERE accessionNo = '$accessionNo'";
	
	my @geneInfo = DBinterface::DoQuery($sqlQuery);
	
	# Get gene name , if unnamed set to unnamed.
	my $geneName = 0;
	
	# Data to return

	# Codon usage
	# RES sites

	# Build hash
	
	# Hash to save all data in.
	my %geneData;
	
	# Gene name
	$geneData{$accessionNo}{'GeneName'} = $geneInfo[0]->[0];
	
	# Chomosome location 
	$geneData{$accessionNo}{'ChromLoc'} = $geneInfo[0]->[1];
	
	# Protein product
	$geneData{$accessionNo}{'ProteinProduct'} = $geneInfo[0]->[2];
	
	# DNA sequence
	$geneData{$accessionNo}{'GeneSeq'} = $geneInfo[0]->[3];
	
	# Amino acid sequence
	$geneData{$accessionNo}{'ProteinSeq'} = $geneInfo[0]->[4]; 

	
	# Send back hash of data
	return %geneData;
}
###########################################################################################################
#
# GetCodonUsage - Takes an accession number and returns an array with codon usage numbers from DB.
#
##########################################################################################################
sub GetCodonUsage( $ ){
	my $accessionNo = $_[0];
	
	my $sqlQuery = "SELECT codonCount FROM codonBias WHERE accessionNo = '$accessionNo'";
	
	my @codonUsage = DBinterface::DoQuery($sqlQuery);
	
	print Dumper(@codonUsage);
	 
}


##########################################################################################################
#
# databaseConnect - Takes database name, username, password and server name, returns handle to DB or undef.
# let the caller handle success and fail of connect.
#
##########################################################################################################
sub databaseConnect{
	
	#Defined the connection details to the database
	my $dbname = 'scouls01'; 
	my $user = 'scouls01';
	my $password = 'iwr8sh8vb'; 
	my $dbserver = 'localhost';
	
	# my $dbname = 'biocomp2'; 
	# my $user = 'c2';
	# my $password = 'coursework123'; 
	# my $dbserver = 'localhost';
	
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
# isArrayEmpty - Takes an array as input and returns true if it is empty or false if not empty
#
##########################################################################################################
sub isArrayEmpty( @ ){
	
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
				return 1; # Has length or is equal to N/A
			}
		}
	}
	# All item were zero length or N/A, array was empty, return 0 for success or has data
	return 0;
}

sub GetLastErrorMessage{
	return $lastErrorMessage;
}

sub SetLastErrorMessage( $ ){
	$lastErrorMessage = $_[0];
}
# Constants

use constant FALSE => 1;
use constant TRUE => 0;

# Global variables

my $lastErrorMessage = '';

1;
