package ChromoDB;
use Data::Dumper;
use DBinterface;


#CALLED FROM WEBSITE

##########################################################################################################
#
# ShowAllIdentifiers - Takes handle to the database returns an array containing any items in the requested 
#
##########################################################################################################
sub ShowAllIdentifiers( $ ){
	
	# Get the second input, first is the SOAP class variable
	my $id = $_[0];
	my %error = ();
	# Check for blank input, return error is zero length
	unless( $id ){
		$error{'error'} = 'ERROR:ZERO_LENGTH_ARGUMENT';
		return %error;
	}

	# Decide what type of identifier has been passed in and put it 
	# into a variable that will correspond to a column in the DB
	my $idType = DBinterface::getIdentifier( $id );
	unless( $idType ){
		$error{'error'} = DBinterface::GetLastErrorMessage();
		return %error;
	}
	
	# Run query in DB and check that actual data was returned.  
	my @columnData = DBinterface::QueryColumn( $idType );
	unless( @columnData ){
		$error{'error'} = DBinterface::GetLastErrorMessage();
		return %error;
	}
	
	# Hash for the accession number and identifier
	my %columnIdentifiers = ();
	
	# Iterate over returned array for column and fill out hash
	# NOTE: Some accession numbers have no a chromosome locations
	# for now pass back everything.
	for($i = 0; $i < @columnData; $i++){
		$columnIdentifiers{$i}{'accession'} = $columnData[$i][0];
		$columnIdentifiers{$i}{'identifier'} = $columnData[$i][1];
	}
		
	# Return the list of identifiers
	return %columnIdentifiers;
}


##########################################################################################################
#
# getSearchResults - Takes a string from the webpage and searches the database for matches
#
##########################################################################################################
sub getSearchResults{
	
	# Get and store the input arguments, $class because of SOAP calling it.
	my ($searchString, $idType) = @_;
	
	my %error = ();
	
	# Check for blank arguments passed in
	if(($searchString eq '') || ($idType eq '')){
		$error{'error'} = 'ERROR:ZERO_LENGTH_ARGUMENT';
		return %error;
	}
	
	# Convert requested identifier type to a DB column name
	my $id = DBinterface::getIdentifier($idType);
	unless( $id ){
		$error{'error'} = DBinterface::GetLastErrorMessage();
		return %error;
	}
	
	# Send a search query to the DB
	my @queryResult = DBinterface::querySearch($searchString, $id);
	
	# String must contain matches to return
	unless( @queryResult ){
	
		# If is null return null string or error code
		$error{'error'} = DBinterface::GetLastErrorMessage();
		return %error; 	
		
	}else{
		# Hash to hold the data associated with each search results accessionNo
		my %searchResults;
	
		for(my $i = 0; $i < @queryResult; $i++){
			# Name each entry by accession number
			$accessionNumber = $queryResult[$i]->[0];
			
			# Fill out the hash entry with all the data associated with the accessionNo
			$searchResults{$accessionNumber}{'GeneName'} = $queryResult[$i]->[1];
			$searchResults{$accessionNumber}{'ChromosomeLocation'} = $queryResult[$i]->[2];
			$searchResults{$accessionNumber}{'ProteinName'} = $queryResult[$i]->[3];
			$searchResults{$accessionNumber}{'ProteinId'} = $queryResult[$i]->[4];
			$searchResults{$accessionNumber}{'GeneLength'} = $queryResult[$i]->[5];
			
			# Retrieve coding sequence data for given accession number
			# Need error checking for below and a messge to indicate if there
			# is no data.
			my @sequence = DBinterface::buildCodingSeq($queryResult[$i]->[0]);
			$searchResults{$accessionNumber}{'SeqFeat'} = [@sequence];
		}

		# Return the hash to JSON
		return %searchResults;

	}
	
}

##########################################################################################################
# 
# getSequence - Takes an identifier and returns the whole sequence as a string
#
##########################################################################################################
sub getSequence{
	
	# Get and store the input arguments, $class because of SOAP calling it.
	my ($accessionNo, $seqType) = @_;
	
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
sub showCodingSeq{

	# Get and store the input arguments, $class because of SOAP calling it.
	my ( $accessionNo ) = @_;
	
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
	my $geneName = 0;
	
	# Get gene ID
	
	# Perhaps gene location
	
	# Get coding data for it.
	
	# Package in to hash and send back
}

sub returnArray(){
	my @array = {"one","two","three","four"};
	return @array;
}











1;
