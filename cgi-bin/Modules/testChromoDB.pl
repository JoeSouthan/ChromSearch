#!/usr/bin/perl

use SOAP::Lite;

################################ TEST: 'SOAP server is working' ################################

# Check SOAP server works
print "Checking connection to connection to SOAP server\n";
print "\nCalling the SOAP server...\n";
print "The SOAP server says:\n";
use SOAP::Lite +autodispatch =>
    uri => 'urn:ChromoDB',
    #proxy => 'http://student.cryst.bbk.ac.uk/cgi-bin/cgiwrap/scouls01/SOAPProxy.pl';
    proxy => 'http://joes-pi.dyndns.org/cgi-bin/proxy.pl';

print sayHello("Test Script");
print "\n\n";

################################ TEST: 'showAllIdentifiers' ################################

# TEST 'showAllIdentifiers'
print "************************** TEST : 'showAllIdentifiers' **************************\n";

# CONDITION: Column empty
print "\nTesting 'showAllIdentifiers' with no identifier specified\n";
my $id = showAllIdentifiers('');
if( $id eq 'ERROR:ZERO_LENGTH_ARGUMENT'){
	print "Returned: ",$id,"\nPassed\n";
}else{
	print "Returned: ",$id,"\nFailed\n";
}
	
# CONDITION: Incorrect identifier
print "\nTesting 'showAllIdentifiers' with invalid identifier specified\n";
my $id = showAllIdentifiers("geneseq");
if( $id eq 'ERROR:UNRECOGNIZED_ID'){
	print "Returned: ",$id,"\nPassed\n";
}else{
	print "Returned: ",$id,"\nFailed\n";
}

# CONDITION: Column empty - NOTE: Only works when column left blank on purpose 
#print "\nTesting 'showAllIdentifiers' with valid identifier specified but no entry in DB\n";
#my $id = showAllIdentifiers("ProteinSeq");
#if( $id eq 'ERROR:NO_DB_MATCHES'){
#	print "Returned: ",$id,"\nPassed\n";
#}else{
#	print "Returned: ",$id,"\nFailed\n";
#}

# CONDITION: Correct parameters
print "\nTesting 'showAllIdentifiers' with correct parameter 'GeneID'\n";
my $items = showAllIdentifiers("GeneID");
if( 0 ne length($items)){
	print "Returned: ",$items,"\nPassed\n";
}else{
	print "Returned: ",$items,"\nFailed\n";
}

################################ TEST: 'getSearchResults' ################################

# TEST 'getSearchResults'
print "************************** TEST : 'getSearchResults' **************************\n";

# CONDITION: No parameters
print "\nTesting 'getSearchResults' with no parameters\n";
my $results = getSearchResults("","");
if( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: Correct parameters of Test1234 (assumes this dummy data is in DB) and GeneID
print "\nTesting 'getSearchResults' '2627128' and 'GeneID' as parameters\n";
my $results = getSearchResults("2627128","GeneID");
if( $results eq '2627128'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: Correct parameters of DNA primase 1 (assumes this dummy data is in DB) and ProteinProduct
print "\nTesting 'getSearchResults' 'DNA primase 1' and 'ProteinProduct' as parameters\n";
my $results = getSearchResults("DNA primase 1","ProteinProduct");
if( $results eq 'DNA primase 1'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: Correct parameters of AB002805 (assumes this dummy data is in DB) and AccessionNumber
print "\nTesting 'getSearchResults' 'AB002805' and 'AccessionNumber' as parameters\n";
my $results = getSearchResults("AB002805","AccessionNumber");
if( $results eq 'AB002805'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: Correct parameters of q13 (assumes this dummy data is in DB) and ChromosomeLocation
print "\nTesting 'getSearchResults' 'q13' and 'ChromosomeLocation' as parameters\n";
my $results = getSearchResults("q13","ChromosomeLocation");
if( $results eq 'q13'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: Correct parameters of but not in DB
print "\nTesting 'getSearchResults' '4p4.2' and 'ChromosomeLocation' as parameters\n";
my $results = getSearchResults("4p4.2","ChromosomeLocation");
if( $results eq 'ERROR:NO_DB_MATCHES'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION Partial words in search string.

################################ TEST: 'getSequence' ################################

# TEST 'getDNAsequence'
print "************************** TEST : 'getSequence' **************************\n";

# CONDITION: No arguments

print "\nTesting 'getSequence' with no parameters\n";
my $results = getSequence('');
if( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT'){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: With valid accession number

print "\nTesting 'getSequence' with valid accession number\n";
my $results = getSequence('AB002805', 'GeneSeq');
if( length($results) ){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

################################ TEST: 'showCodingSeq' ################################

# TEST 'showCodingSeq'
print "************************** TEST : 'showCodingSeq' **************************\n";

# CONDITION: No arguments

print "\nTesting 'showCodingSeq' with no parameters\n";
my $results = showCodingSeq('');
if( $results eq 'ERROR:ZERO_LENGTH_ARGUMENT' ){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

# CONDITION: No arguments

print "\nTesting 'showCodingSeq' with valid arguments\n";
my $results = showCodingSeq('AB002805');
if( length($results) ){
	print "Returned: ",$results,"\nPassed\n";
}else{
	print "Returned: ",$results,"\nFailed\n";
}

