package DBinterface;

use DBI;

use strict;

use diagnostics;

# Subroutines

# Database facing

# showCodingSeq - Takes an identifier and returns an array of the introns and exons sequecntially ordered
sub showCodingSeq(){
	return 1;
}

# sanSearch - Takes as search string and returns a sanitized search string
sub sanSearch( $ ){
	return 1;
}

# getIdentifier - Takes an indentifer and returns an indentifer that complies with the DB column names.

sub getIdentifier( $ ){

	#***Check with Matt on what the column names will be***
	
	my ($id, $idType) = "";
	
	if($_[0] eq ''){
		return "Identifier empty\n";
		#return '';
	}else{
		$id = $_[0];
	}
	
	if( $id eq "GeneID" ) {
			$idType = "geneID";
	}elsif($id eq "ProteinProduct"){
			$idType = "proteinName";
	}elsif($id eq "Accession"){
			$idType = "";
	}elsif($id eq "ChromosomeLocation"){
			$idType = "";
	}
	
	return $idType;
}

# querySearch - Takes a search string and type, returns comma separated list of search results
sub querySearch($$){
	
	# Get the function parameters
	my ($searchString, $idType) = @_;
	
	# Convert requested identifier type to a DB column name
	my $id = getIdentifier($idType);
	
	# Connect to database 
	my $hDb = DBinterface::databaseConnect( "biocomp2","c2","coursework123", "localhost");
	
	# Run search query
	my $sqlQuery = "SELECT $id FROM gene WHERE $id=$searchString";
	
	my $queryRows = $hDb->prepare($sqlQuery);
	
	my @id;
	
	if($queryRows->execute)
	{
	
		while(my $row = $queryRows->fetchrow_array){
			push(@id, $row);
		}
		
		my $string = join(",",@id);
		
		return $string;
	}

	return "";
}  

# queryColumn - Takes a column id and returns elements of a single column
sub queryColumn{

	# Assumes the identifer passed will be in the correct form as this should only every be called from code
	# so no need to check it.
	
	my ($rowId) = @_;
	
	# Connect to database 
	my $hDb = DBinterface::databaseConnect( "biocomp2","c2","coursework123", "localhost");
	
	# Run search query
	my $sqlQuery = "SELECT $rowId FROM gene";
	
	my $queryRows = $hDb->prepare($sqlQuery);
	
	my @id;
	
	if($queryRows->execute)
	{
	
		while(my $row = $queryRows->fetchrow_array){
			push(@id, $row);
		}
		
		my $string = join(",",@id);
		
		return $string;
	}

	return "";
}
 
# querySeqDNA - Takes an identifer and returns the DNA sequecne for it from the DB.
sub querySeqDNA( $ ){
	return 1;
}

# querySeqAA - Takes an identifier and returns the AA sequecne for it from the DB.
sub querySeqAA( $ ){
	return 1;
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

# buildCodingSeq - Takes an Id and returns an array with all the introns and exons in sequence.
sub buildCodingSeq( $ ){
	return 1;
}

# databaseConnect - Takes DBname, username, password and URL, returns succes of fail.
# let the caller handle success and fail of connect.
sub databaseConnect( $$$$ ){
	
	# fill out variable from the function arguments
	my ($dbname, $user, $password, $dbserver) = @_;
	
	# Specify the location and name of the database
	my $datasource = "dbi:mysql:database=$dbname;host=$dbserver";
	
	# Attempt to connect to the database (turn off DBI error reporting )
	my $dbh = DBI->connect($datasource, $user, $password, {PrintError => 0});
	
	if( $dbh )
	{
		# Return handle to database
		return $dbh;
	}else{
		return 1;
	}
}

# Constants

use constant FAIL => 1;
use constant SUCCESS => 0;

# Global variables

1;
