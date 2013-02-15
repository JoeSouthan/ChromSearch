#! /usr/bin/perl 

use DBinterface;

use strict;

################################ TEST: 'databaseConnect'###############################

print "************************** TEST : 'databaseConnect' **************************\n";

# CONDITION: Just run function

print "\nTesting 'databaseConnect'\n";
my $dbhandle = DBinterface::databaseConnect();
if( defined($dbhandle) ){
	print "Passed\n";
}elsif(undef == $dbhandle){
	print "Failed\n"
}

################################ TEST: 'queryRun'###############################

print "\n************************** TEST : 'queryRun' **************************\n";


# CONDITION: Valid string 'SELECT geneID FROM gene WHERE geneID='Test1234''

print "\nTesting 'queryRun' with valid string 'SELECT geneID FROM gene WHERE geneID='Test1234'\n";
my $sqlQuery = "SELECT geneID FROM gene WHERE geneID='Test1234'";
my @queryData = DBinterface::queryRun($sqlQuery);
if(0 != length(@queryData[0])){
	print "Returned ",@queryData,"\nPassed\n";
}else{
	print "Returned ",@queryData,"\nFailed\n";
}

# CONDITION: Valid string 'SELECT geneID FROM gene'

print "\nTesting 'queryRun' with valid string for many rows\n";
my $sqlQuery = "SELECT geneID FROM gene";
my @queryData = DBinterface::queryRun($sqlQuery);
if(0 != length(@queryData[0])){
	print "Returned ",@queryData,"\nPassed\n";
}else{
	print "Returned ",@queryData,"\nFailed\n";
}

################################ TEST: 'queryColumn'###############################

print "\n************************** TEST : 'queryColumn' **************************\n";

# CONDITION: Identifer of empty column

#print "\nTesting 'queryColumn' with identifier of empty column\n";
#my $id = DBinterface::queryColumn('proteinSeq');
#if($id eq 'ERROR:DB_COLUMN_EMPTY'){
#	print "Returned ",$id,"\nPassed\n";
#}else{
#	print "Returned ",$id,"\nFailed\n";
#}

# CONDITION: Valid function arguments

print "\nTesting 'queryColumn' with valid function arguments\n";
my $id = DBinterface::queryColumn('geneID');
if( 0 != length($id) ){
	print "Returned ",$id,"\nPassed\n";
}else{
	print "Returned ",$id,"\nFailed\n";
}

################################ TEST 'querySearch' ###############################

print "\n************************** TEST: 'querySearch' **************************\n";

# CONDITION: Valid parameters for geneId

print "\nTesting 'querySearch' with valid parameters 'Test1234' as search string and 'geneId' as identifier type\n";
my $results = DBinterface::querySearch("Test1234","geneId");
if( $results eq 'Test1234' ){
	print "Returned ",$results,"\nPassed\n";
}else{
	print "$results\n";
}

# CONDITION: Valid parameters for proteinName

print "\nTesting 'querySearch' with valid parameters 'HEX1' as search string and 'proteinName' as type\n";
my $results = DBinterface::querySearch("HEX1","proteinName");
if( $results eq 'HEX1' ){
	print "Returned ",$results,"\nPassed\n";
}else{
	print "$results\n";
}

# CONDITION: Valid parameters for Accession number

print "\nTesting 'querySearch' with valid parameters 'AB002805' as search string and 'accessionNo' as type\n";
my $results = DBinterface::querySearch("AB002805","accessionNo");
if( $results eq 'AB002805' ){
	print "Returned ",$results,"\nPassed\n";
}else{
	print "Returned ",$results,"\nFailed\n";
}

# CONDITION: Valid parameters for chromosome location

print "\nTesting 'querySearch' with valid parameters '4p12.2' as search string and 'chromLoc' as type\n";
my $results = DBinterface::querySearch("4p12.2","chromLoc");
if( $results eq '4p12.2' ){
	print "Returned ",$results,"\nPassed\n";
}else{
	print "Returned ",$results,"\nFailed\n";
}


# CONDITION: Valid parameters but not in DB

print "\nTesting 'querySearch' with valid parameters but not in DB\n";
my $results = DBinterface::querySearch("HEX5","proteinName");
if( $results eq 'ERROR:NO_DB_MATCHES' ){
	print "Returned ",$results,"\nPassed\n";
}else{
	print "Returned ",$results,"\nFailed\n";
}

################################ TEST 'getIdentifier' ###############################

print "\n************************** TEST: 'getIdentifier' **************************\n";

# CONDITION: Valid parameters

print "\nTesting 'getIdentifier' with valid parameter 'GeneID'\n";
my $identifier = DBinterface::getIdentifier("GeneID");
if($identifier eq 'geneID'){
	print "Returned ",$identifier,"\nPassed\n";
}else{
	print "Returned ",$identifier,"\nFailed\n";
}

# CONDITION: Incorrect parameters

print "\nTesting 'getIdentifier' with incorrect parameter 'geneidentifier'\n";
my $identifier = DBinterface::getIdentifier("geneindentifier");
if($identifier eq 'ERROR:UNRECOGNIZED_ID'){
	print "Returned ",$identifier,"\nPassed\n";
}else{
	print "Returned ",$identifier,"\nFailed\n";
}

################################ TEST : 'isArrayEmpty' ################################

# CONDITION: Array with items in 

print "\n************************** TEST: 'isArrayEmpty' **************************\n";
print "\nTesting 'isArrayEmpty' with valid filled out array\n";
my @items = ("one","two","three");
my $result = DBinterface::isArrayEmpty( @items );
if($result eq 'FALSE'){
	print "Returned ",$result,"\nPassed\n";
}else{
	print "Returned ",$result,"\nFailed\n";
}


# CONDITION: Array with blank entries

print "\n************************** TEST: 'isArrayEmpty' **************************\n";
print "\nTesting 'isArrayEmpty' with blank array elements\n";
my @items = ('','','','');
my $result = DBinterface::isArrayEmpty( @items );
if($result eq 'TRUE'){
	print "Returned ",$result,"\nPassed\n";
}else{
	print "Returned ",$result,"\nFailed\n";
}

# CONDITION: Array with 'N/A' as array elements 

print "\n************************** TEST: 'isArrayEmpty' **************************\n";
print "\nTesting 'isArrayEmpty' with 'N/A' array elements\n";
my @items = ('N/A','N/A','N/A','N/A');
my $result = DBinterface::isArrayEmpty( @items );
if($result eq 'TRUE'){
	print "Returned ",$result,"\nPassed\n";
}else{
	print "Returned ",$result,"\nFailed\n";
}

# CONDITION: Array with mixed blank and 'N/A' as array elements 

print "\n************************** TEST: 'isArrayEmpty' **************************\n";
print "\nTesting 'isArrayEmpty' with mixed blank and 'N/A' array elements\n";
my @items = ('N/A','','N/A','');
my $result = DBinterface::isArrayEmpty( @items );
if($result eq 'TRUE'){
	print "Returned ",$result,"\nPassed\n";
}else{
	print "Returned ",$result,"\nFailed\n";
}

# CONDITION: Array with one of the elements as valid

print "\n************************** TEST: 'isArrayEmpty' **************************\n";
print "\nTesting 'isArrayEmpty' with one of the elements as valid\n";
my @items = ('N/A','','N/A','Hello','' );
my $result = DBinterface::isArrayEmpty( @items );
if($result eq 'FALSE'){
	print "Returned ",$result,"\nPassed\n";
}else{
	print "Returned ",$result,"\nFailed\n";
}

################################ TEST : 'querySeqDNA' ################################

print "\n************************** TEST: 'querySequence' **************************\n";
print "\nTesting 'querySequence' with no sequence data\n";
my $seq = DBinterface::querySequence('232322', 'ProteinSeq');
if( $seq eq 'ERROR:DB_COLUMN_EMPTY'){
	print "Returned ",$seq,"\nPassed\n";
}else{
	print "Returned ",$seq,"\nFailed\n";
}


print "\n************************** TEST: 'querySequence' **************************\n";
print "\nTesting 'querySequence' with valid argument accession number 'AB002805'\n";
my $seq = DBinterface::querySequence('AB002805', 'GeneSeq');
if( length($seq) ){
	print "Returned ",$seq,"\nPassed\n";
}else{
	print "Returned ",$seq,"\nFailed\n";
}


################################ TEST : 'buildCodingSeq' ################################

print "\n************************** TEST: 'buildCodingSeq' **************************\n";
print "\nTesting 'buildCodingSeq' with valid argument accession number 'AB002805'\n";
my @seq = DBinterface::buildCodingSeq('AB002805');
if( length(@seq) ){
	print "Returned ",@seq,"\nPassed\n";
}else{
	print "Returned ",@seq,"\nFailed\n";
}


