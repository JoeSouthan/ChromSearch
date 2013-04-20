#!/usr/bin/perl
use Test::Simple tests => 18;
use Data::Dumper;
use strict;
#use warnings;

use ChromoDB;

################################ TEST: 'ShowAllIdentifiers' ################################

# TEST 'ShowAllIdentifiers'

print "************************** TEST : 'ShowAllIdentifiers' **************************\n";

# CONDITION: with no identifier specified
{
	my %id = ChromoDB::ShowAllIdentifiers('');
	ok( $id{'error'} eq 'ERROR:ZERO_LENGTH_ARGUMENT' ,"with no identifier specified");
	#print Dumper(%id);
}

# CONDITION: Incorrect identifier
{
	my %id = ChromoDB::ShowAllIdentifiers('geneseq');
	ok( $id{'error'} eq 'ERROR:UNRECOGNIZED_ID',"with invalid identifier specified");
}

# CONDITION: Column empty - NOTE: Only works when column left blank on purpose 

#my $id = showAllIdentifiers("ProteinSeq");
#ok( $id eq 'ERROR:NO_DB_MATCHES',"with valid identifier specified but no entry in DB" );

# CONDITION: Valid argument 'GeneID'
{
	my %items = ChromoDB::ShowAllIdentifiers('GeneID');
	ok( %items, "with valid argument 'GeneID'");
	#print Dumper(%items);
}

# CONDITION: Valid argument 'ProteinName'
{
	my %items = ChromoDB::ShowAllIdentifiers('ProteinProduct');
	ok( %items, "with correct parameter 'ProteinName'");
	#print Dumper(%items);
}

# CONDITION: Valid argument 'ChromosomeLocation'
{
	my %items = ChromoDB::ShowAllIdentifiers('ChromosomeLocation');
	ok( %items, "with correct parameter 'ChromosomeLocation'");
	#print Dumper(%items);
}

################################ TEST: 'getSearchResults' ################################

# TEST 'getSearchResults'
print "************************** TEST : 'getSearchResults' **************************\n";

# CONDITION: No parameters
{
	my %results = ChromoDB::getSearchResults("","");
	ok( $results{'error'} eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of 2780780 (assumes this dummy data is in DB) and GeneID
{
	my %results = ChromoDB::getSearchResults("2780780","GeneID");
	ok( %results, "with '2780780' and 'GeneID' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of DUSP6 (assumes this dummy data is in DB) and ProteinProduct
{
	my %results = ChromoDB::getSearchResults("DUSP6","ProteinProduct");
	ok( %results, "with 'DUSP6' and 'ProteinProduct' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of AB002805 (assumes this dummy data is in DB) and AccessionNumber
{
	my %results = ChromoDB::getSearchResults('AB002805','AccessionNumber');
	ok( %results, "with '2780780' and 'AccessionNumber' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of q13 (assumes this dummy data is in DB) and ChromosomeLocation
{
	my %results = ChromoDB::getSearchResults('q13','ChromosomeLocation');
	ok( %results, "with 'q13' and 'ChromosomeLocation' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct agrument but AccessionNumber not in DB
{
	my %results = ChromoDB::getSearchResults('AB0000000','AccessionNumber');
	ok( $results{'error'} eq 'DB_RETURNED_NO_MATCHES', "with invalid AccessionNumber argument");
	#print Dumper(%results);
}

# CONDITION Partial words in search string.
{
	my %results = ChromoDB::getSearchResults('AB00','AccessionNumber');
	ok( %results, "with partial AccessionNumber argument");
	#print Dumper(%results);
}

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
	my @codingSeq = ChromoDB::showCodingSeq('');
	ok( @codingSeq, "with no arguments");
	print Dumper(@codingSeq);
}
# CONDITION: With valid accession number as argument 
{
	my @codingSeq = ChromoDB::showCodingSeq('AB002805');
	ok( @codingSeq, "with valid accession number AB002805 as an argument");
	print Dumper(@codingSeq);
}

################################ TEST: 'GetGeneSummaryData' ################################

# TEST 'GetGeneSummaryData'
print "************************** TEST : 'GetGeneSummaryData' **************************\n";

# CONDITION: No arguments
{
	my %data = ChromoDB::GetGeneSummaryData('');
	ok( $data{'error'} eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no arguments");
}
# CONDITION: With valid accession number as argument 
{
	my %data = ChromoDB::GetGeneSummaryData('AB002805');
	ok( %data, "with valid accession number AB002805 as an argument");
	#print Dumper(%data);
}

################################ TEST: 'GetRES' ################################

# TEST 'GetRES'
print "************************** TEST : 'GetRES' **************************\n";

# CONDITION: No arguments
{
	my %RESdata = ChromoDB::GetRES();
	ok( %RESdata, "with no arguments");
	#print Dumper(%RESdata);
}

