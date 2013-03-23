#!/usr/bin/perl
use Test::Simple tests => 13;

use strict;
#use warnings;

use ChromoDB;

################################ TEST: 'showAllIdentifiers' ################################

# TEST 'showAllIdentifiers'
print "************************** TEST : 'showAllIdentifiers' **************************\n";


# CONDITION: Column empty
{
	my $id = ChromoDB::showAllIdentifiers('');
	ok( $id eq 'ERROR:ZERO_LENGTH_ARGUMENT',"with no identifier specified");
}

# CONDITION: Incorrect identifier
{
	my $id = ChromoDB::showAllIdentifiers("geneseq");
	ok( $id eq 'ERROR:UNRECOGNIZED_ID',"with invalid identifier specified");
}

# CONDITION: Column empty - NOTE: Only works when column left blank on purpose 

#my $id = showAllIdentifiers("ProteinSeq");
#ok( $id eq 'ERROR:NO_DB_MATCHES',"with valid identifier specified but no entry in DB" );

# CONDITION: Correct parameters
{
	my $items = ChromoDB::showAllIdentifiers("GeneID");
	ok( 0 ne length($items), "with correct parameter 'GeneID'");
}

################################ TEST: 'getSearchResults' ################################

# TEST 'getSearchResults'
print "************************** TEST : 'getSearchResults' **************************\n";

# CONDITION: No parameters
{
	my $results = ChromoDB::getSearchResults("","");
	ok( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");
}

# CONDITION: Correct parameters of 2780780 (assumes this dummy data is in DB) and GeneID
{
	my %results = ChromoDB::getSearchResults("2780780","GeneID");
	ok( $results{'AB002805'}{'GeneName'} eq '2780780', "with '2780780' and 'GeneID' as parameters");
	print $results{'AB002805'}{'GeneName'},"\n";
}

# CONDITION: Correct parameters of DUSP6 (assumes this dummy data is in DB) and ProteinProduct
{
	my %results = ChromoDB::getSearchResults("DUSP6","ProteinProduct");
	ok( $results{'AB013601'}{'GeneName'} eq '60683881', "with 'DUSP6' and 'ProteinProduct' as parameters");
	print $results{'0'}{'GeneName'},"\n";
}
# CONDITION: Correct parameters of AB002805 (assumes this dummy data is in DB) and AccessionNumber
{
	my %results = ChromoDB::getSearchResults("AB002805","AccessionNumber");
	ok( $results{'AB002805'}{'GeneName'} eq '2780780', "with '2780780' and 'AccessionNumber' as parameters");
	#print $results{'AB002805'}{'GeneName'},"\n";
}
# CONDITION: Correct parameters of q13 (assumes this dummy data is in DB) and ChromosomeLocation
{
	my %results = ChromoDB::getSearchResults("q13","ChromosomeLocation");
	ok( %results, "with 'q13' and 'ChromosomeLocation' as parameters");
	while(my ( $key, $value ) = each %results ){
		print "$key=$value\n";
	}
}
# CONDITION: Correct parameters of but not in DB

#my $results = ChromoDB::getSearchResults("4p4.2","ChromosomeLocation");
#ok( $results eq 'ERROR:NO_DB_MATCHES', "with '4p4.2' and 'ChromosomeLocation' as parameters");

# CONDITION Partial words in search string.

################################ TEST: 'getSequence' ################################

# TEST 'getDNAsequence'
print "************************** TEST : 'getSequence' **************************\n";

# CONDITION: No arguments
{
	my $results = ChromoDB::getSequence('');
	ok( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");
}
# CONDITION: With valid accession number
{
	my $results = ChromoDB::getSequence('AB002805', 'GeneSeq');
	ok( length($results), "with valid accession number");
}
################################ TEST: 'showCodingSeq' ################################

# TEST 'showCodingSeq'
print "************************** TEST : 'showCodingSeq' **************************\n";

# CONDITION: No arguments
{
	my $results = ChromoDB::showCodingSeq('');
	ok( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no arguments");
}
# CONDITION: No arguments
{
	my $results = ChromoDB::showCodingSeq('AB002805');
	ok( length($results), "with valid accession number AB002805 as an argument");
	print $results,"\n";
}
################################ TEST: 'misc' ################################


