#!/usr/bin/perl
use Test::Simple tests => 13;
use SOAP::Lite;

################################ TEST: 'SOAP server is working' ################################

# Check SOAP server works
print "Checking connection to connection to SOAP server\n";
print "\nCalling the SOAP server...\n";
print "The SOAP server says:\n";
use SOAP::Lite +autodispatch =>
    uri => 'urn:ChromoDB',
    proxy => 'http://student.cryst.bbk.ac.uk/cgi-bin/cgiwrap/scouls01/SOAPProxy.pl';
    #proxy => 'http://joes-pi.dyndns.org/cgi-bin/proxy.pl';

print sayHello("Test Script");
print "\n\n";

################################ TEST: 'showAllIdentifiers' ################################

# TEST 'showAllIdentifiers'
print "************************** TEST : 'showAllIdentifiers' **************************\n";


# CONDITION: Column empty

my $id = showAllIdentifiers('');
ok( $id eq 'ERROR:ZERO_LENGTH_ARGUMENT',"with no identifier specified");


# CONDITION: Incorrect identifier

my $id = showAllIdentifiers("geneseq");
ok( $id eq 'ERROR:UNRECOGNIZED_ID',"with invalid identifier specified");

# CONDITION: Column empty - NOTE: Only works when column left blank on purpose 

#my $id = showAllIdentifiers("ProteinSeq");
#ok( $id eq 'ERROR:NO_DB_MATCHES',"with valid identifier specified but no entry in DB" );

# CONDITION: Correct parameters

my $items = showAllIdentifiers("GeneID");
ok( 0 ne length($items), "with correct parameter 'GeneID'");

################################ TEST: 'getSearchResults' ################################

# TEST 'getSearchResults'
print "************************** TEST : 'getSearchResults' **************************\n";

# CONDITION: No parameters

my $results = getSearchResults("","");
ok( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");

# CONDITION: Correct parameters of 2780780 (assumes this dummy data is in DB) and GeneID

my $results = getSearchResults("2780780","GeneID");
ok( $results eq 'AB002805:2780780', "with '2780780' and 'GeneID' as parameters");
#print $results;

# CONDITION: Correct parameters of DUSP6 (assumes this dummy data is in DB) and ProteinProduct

my $results = getSearchResults("DUSP6","ProteinProduct");
ok( $results eq 'AB013601:60683881', "with 'DNA primase 1' and 'ProteinProduct' as parameters");
#print $results;

# CONDITION: Correct parameters of AB002805 (assumes this dummy data is in DB) and AccessionNumber

my $results = getSearchResults("AB002805","AccessionNumber");
ok( $results eq 'AB002805:2780780', "with 'AB002805' and 'AccessionNumber' as parameters");
#print $results;

# CONDITION: Correct parameters of q13 (assumes this dummy data is in DB) and ChromosomeLocation

my $results = getSearchResults("q13","ChromosomeLocation");
ok( length($results), "with 'q13' and 'ChromosomeLocation' as parameters");
print $results;

# CONDITION: Correct parameters of but not in DB

my $results = getSearchResults("4p4.2","ChromosomeLocation");
ok( $results eq 'ERROR:NO_DB_MATCHES', "with '4p4.2' and 'ChromosomeLocation' as parameters");

# CONDITION Partial words in search string.

################################ TEST: 'getSequence' ################################

# TEST 'getDNAsequence'
print "************************** TEST : 'getSequence' **************************\n";

# CONDITION: No arguments

my $results = getSequence('');
ok( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");

# CONDITION: With valid accession number

my $results = getSequence('AB002805', 'GeneSeq');
ok( length($results), "with valid accession number");

################################ TEST: 'showCodingSeq' ################################

# TEST 'showCodingSeq'
print "************************** TEST : 'showCodingSeq' **************************\n";

# CONDITION: No arguments

my $results = showCodingSeq('');
ok( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");

# CONDITION: No arguments

my $results = showCodingSeq('AB002805');
ok( length($results), "with valid arguments");


################################ TEST: 'misc' ################################

my %rarray = returnArray();
foreach my $val (@rarray){
	print $val;
}

