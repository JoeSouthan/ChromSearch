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
	my $idType = DBinterface::GetIdentifier( $id );
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
	my $id = DBinterface::GetIdentifier($idType);
	unless( $id ){
		$error{'error'} = DBinterface::GetLastErrorMessage();
		return %error;
	}
	
	# Send a search query to the DB
	my @queryResult = DBinterface::QuerySearch($searchString, $id);
	
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
			my @sequence = DBinterface::BuildCodingSeq($queryResult[$i]->[0]);
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
	my $seqTypeID = DBinterface::GetIdentifier($seqType);
	
	my $seq = DBinterface::QuerySequence( $accessionNo, $seqTypeID );
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

	my @codingSeq = DBinterface::BuildCodingSeq($accessionNo);
	if(@codingSeq eq 'ERROR:DB_COLUMN_EMPTY'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}
	
	# Return array or can be string if we want?.
	return @codingSeq;
}

# GetGeneSummaryData - Takes an accession number and returns GeneID, Gene Name, and the Seqeuence data annotated

sub GetGeneSummaryData{
	# Get and store the input arguments, $class because of SOAP calling it.
	my ( $accessionNo ) = $_[0];
	
	# Check for blank arguments passed in
	if( ($accessionNo eq '') ){
		$error{'error'} = 'ERROR:ZERO_LENGTH_ARGUMENT';
		return %error;
	}
	
	my %geneData = DBinterface::BuildSummaryData($accessionNo);
	
	return %geneData;
}



1;
