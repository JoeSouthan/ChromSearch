package ChromoDB;
use strict;
use DBinterface;

# Small test function to make sure SOAP is working
sub sayHello {
   my($class, $user) = @_;
    return "Hello $user from the SOAP server";
}

#CALLED FROM WEBSITE

##########################################################################################################
#
# showAllIdentifiers - Takes handle to the database returns an array containing any items in the requested 
#
##########################################################################################################
sub showAllIdentifiers{
	
	# Get the second input, first is the SOAP class variable
	my $id = $_[1];
	
	# Check for blank input, return error is zero length
	if( 0 == length($id)){
		return 'ERROR:ZERO_LENGTH_ARGUMENT';
	}

	# Decide what type of identifier has been passed in and put it 
	# into a variable that will correspond to a column in the DB
	my $idType = DBinterface::getIdentifier( $id );
	if( $idType eq 'ERROR:UNRECOGNIZED_ID'){
		return 'ERROR:UNRECOGNIZED_ID';
	}
	
	# Run query in DB and check that actual data was returned.  
	my $identifiers = DBinterface::queryColumn($idType);
	if($identifiers eq 'ERROR:DB_COLUMN_EMPTY'){
		# Return data was empty, return error 
		return 'ERROR:NO_DB_MATCHES';
	}
		
	# Return the list of identifiers
	return $identifiers;
}


##########################################################################################################
#
# getSearchResults - Takes a string from the webpage and searches the database for matches
#
##########################################################################################################
sub getSearchResults{
	
	# Get and store the input arguments, $class because of SOAP calling it.
	my ($class, $searchString, $idType) = @_;
	
	# Check for blank arguments passed in
	if(($searchString eq '') || ($idType eq '')){
		return 'ERROR:ZERO_LENGTH_ARGUMENT';
	}
	
	# Convert requested identifier type to a DB column name
	my $id = DBinterface::getIdentifier($idType);
	if($id eq 'ERROR:UNRECOGNIZED_ID'){
		return 'ERROR:UNRECOGNIZED_ID';
	}
	
	# Send a search query to the DB
	my $queryResult = DBinterface::querySearch($searchString, $id);
	
	# If string not empty return the string containing the matches from querySearch
	if(defined($queryResult)){
		return $queryResult;
	}
	else{
		# If is null return null string or error code
		return "ERROR:NO_DB_MATCHES"; # Ask Joe what he would like back if there are no matches
	}
}

##########################################################################################################
# 
# getSequence - Takes an identifier and returns the whole sequence as a string
#
##########################################################################################################
sub getSequence{
	
	# Get and store the input arguments, $class because of SOAP calling it.
	my ($class, $accessionNo, $seqType) = @_;
	
	# Check for blank arguments passed in
	if($accessionNo eq ''){
		return 'ERROR:ZERO_LENGTH_ARGUMENT';
	}
	
	# Expects either 'GeneSeq' or 'ProteinSeq'
	my $seqTypeID = DBinterface::getIdentifier($seqType);
	
	my $seq = DBinterface::querySequence( $accessionNo, $seqTypeID );
	if($seq eq 'ERROR:DB_COLUMN_EMPTY'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}
	
	return $seq;
}

# getSupportedRES - Takes nothing and returns a list of supported restriction enzymes from the DB.
sub getSupportedRES(){
	return 1;
}
##########################################################################################################
# 
# showCodingSeq - Takes an identifier and returns an array of the introns and exons sequentially ordered
#
##########################################################################################################
sub showCodingSeq(){

	# Get and store the input arguments, $class because of SOAP calling it.
	my ($class, $accessionNo) = @_;
	
	# Check for blank arguments passed in
	if($accessionNo eq ''){
		return 'ERROR:ZERO_LENGTH_ARGUMENT';
	}

	my @codingSeq = DBinterface::buildCodingSeq($accessionNo);
	if(@codingSeq eq 'ERROR:DB_COLUMN_EMPTY'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}
	
	# Return array or can be string if we want?.
	return @codingSeq;
}

# getGeneSummaryData - Takes an any of the possible identifers and returns GeneID, Gene Name, and the Seqeuence data annotated

sub getGeneSummaryData{

	# ASSUMPTION: identifer used for search is passed in i.e AccessionNumber or GeneName etc. 
	# Get and store the input arguments 
	my ($class, $identifier) = @_;
	
	# Try to locate the accession number might be more useful to put this in own function
	my $sqlQuery = 'SELECT FROM gene WHERE ';
	
	my $accessionNo = DBinterface::queryRun(); 
	
	# Function should never be called with blank argument as it will be called when the user select from search
	# or browse list.
	
	# hash to save all data in.
	my %geneData;
	
	# Get gene name , if unnamed set to unnamed.
	my $geneName = 
	
	# Get gene ID
	
	# Perhaps gene location
	
	# Get coding data for it.
	
	# Package in to hash and send back
}











1;
