package TestDB;
use DBinterface;
use strict;

sub getSearchResults{
	
	my ($class, $searchString, $idType) = @_;
	return "$searchString , $idType)":
	
	
	# Sanitize the search string
	
	# Send a search query to the DB
	my $queryResult = DBinterface::querySearch($searchString, $idType);
	
	# If string not empty return an array or search string
	if($queryResult ne ""){
		return $queryResult;
	}
	elsif( $queryResult eq ""){
		# If is null return null string or error code
		print "No results found\n";
	}
	
	return "getsearchresults";
}
