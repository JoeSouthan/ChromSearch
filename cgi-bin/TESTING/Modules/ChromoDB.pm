package ChromoDB;

use strict;

use diagnostics;

use DBinterface;

# Web page facing

# showAllIdentifiers - Takes handle to the database returns an array containing any items in the requested 
sub showAllIdentifiers( $ ){
	
	my $id = $_[0];
	my $idType = "";
	
	# Decide what type of identifier has been passed in and put it into a variable that will correspond to a column in the DB
	$idType = DBinterface::getIdentifier( $id );
	
	if($idType eq ""){
		return "Invalid or blank Identifier\n";
		#return '';
	}
	
	# Run query in DB and to see if any identifiers were found.  
	my $identifiers = DBinterface::queryColumn("$idType");
	if($identifiers eq ''){
		# No identifiers, return a blank string
		return '';
	}
		
	# Return the list of identifiers
	return $identifiers;
}



# getSearchResults - Takes a string from the webpage and searches the database for matches
sub getSearchResults( $$ ){
	
	my ($class, $searchString, $idType) = @_;
	
	my $queryResult = "";
	
	# Sanitize the search string
	
	# Send a search query to the DB
	$queryResult = DBinterface::querySearch($searchString, $idType);
	
	# If string not empty return an array or search string
	if($queryResult ne ""){
		return $queryResult;
	}
	elsif( $queryResult eq ""){
		# If is null return null string or error code
		return "No results found\n";
	}
	
	return "";
}

# getDNAsequence - Takes an identifier and returns the whole sequence as a string
sub getDNAsequence( $ ){
	return 1;
}

# getAAsequence - Take an identifier and returns the whole sequecne as a string
sub getAAsequence( $ ){
	return 1;
}

# getSupportedRES - Takes nothing and returns a list of supported restriction enzymes from the DB.
sub getSupportedRES(){
	return 1;
}

1;
