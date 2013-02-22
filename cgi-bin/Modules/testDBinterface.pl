#! /usr/bin/perl 

use strict;
use Test::Simple tests => 19;
use DBinterface;

################################ TEST: 'databaseConnect'###############################

print "\n************************** TEST : 'databaseConnect' **************************\n";

# CONDITION: Just run function
my $dbhandle = DBinterface::databaseConnect();
ok( $dbhandle ne undef,'Test DB connection' );


################################ TEST: 'queryRun'###############################

print "\n************************** TEST : 'queryRun' **************************\n";


# CONDITION: Valid string 'SELECT geneId FROM gene WHERE geneId='Test1234'

my $sqlQuery = "SELECT geneID FROM gene WHERE geneID='Test1234'";
my @queryData = DBinterface::queryRun($sqlQuery);
ok(@queryData, "Testing 'queryRun' with valid string 'SELECT geneID FROM gene WHERE 
geneId'Test1234'");

# CONDITION: Valid string 'SELECT geneId FROM gene'

my $sqlQuery = "SELECT geneId FROM gene";
my @queryData = DBinterface::queryRun($sqlQuery);
ok(@queryData, "Testing 'queryRun' with valid string for many rows");


################################ TEST: 'queryColumn'###############################

print "\n************************** TEST : 'queryColumn' **************************\n";

# CONDITION: Valid function arguments

my $id = DBinterface::queryColumn('geneID');
ok( length($id) ne 0, "Testing 'queryColumn' with valid function arguments" );


################################ TEST 'querySearch' ###############################

print "\n************************** TEST: 'querySearch' **************************\n";

# CONDITION: Valid parameters for geneId

my $results = DBinterface::querySearch("Test1234","geneId");
ok($results eq 'Test1234', 
"with valid parameters 'Test1234' as search string and 'geneId' as identifier type" );

# CONDITION: Valid parameters for proteinName

my $results = DBinterface::querySearch("HEX1","proteinName");
ok( $results eq 'HEX1', 
"with valid parameters 'HEX1' as search string and 'proteinName' as type");

# CONDITION: Valid parameters for Accession number

my $results = DBinterface::querySearch("AB002805","accessionNo");
ok( $results eq 'AB002805',
"with valid parameters 'AB002805' as search string and 'accessionNo' as type");
	

# CONDITION: Valid parameters for chromosome location

my $results = DBinterface::querySearch("4p12.2","chromLoc");
ok( $results eq '4p12.2',
"with valid parameters '4p12.2' as search string and 'chromLoc' as type" );
	
# CONDITION: Valid parameters but not in DB

my $results = DBinterface::querySearch("HEX5","proteinName");
ok( $results eq 'ERROR:NO_DB_MATCHES',"Testing 'querySearch' with valid parameters but not in DB");

################################ TEST 'getIdentifier' ###############################

print "\n************************** TEST: 'getIdentifier' **************************\n";

# CONDITION: Valid parameters

my $identifier = DBinterface::getIdentifier("GeneID");
ok($identifier eq 'geneID', "with valid parameter 'GeneID'");

# CONDITION: Incorrect parameters

my $identifier = DBinterface::getIdentifier("geneindentifier");
ok($identifier eq 'ERROR:UNRECOGNIZED_ID', "with incorrect parameter 'geneidentifier'");

################################ TEST : 'isArrayEmpty' ################################

# CONDITION: Array with items in 

print "\n************************** TEST: 'isArrayEmpty' **************************\n";

my @items = ("one","two","three");
my $result = DBinterface::isArrayEmpty( @items );
ok($result eq 'FALSE', "with valid filled out array" );

# CONDITION: Array with blank entries

my @items = ('','','','');
my $result = DBinterface::isArrayEmpty( @items );
ok($result eq 'TRUE', "with blank array elements");

# CONDITION: Array with 'N/A' as array elements 

my @items = ('N/A','N/A','N/A','N/A');
my $result = DBinterface::isArrayEmpty( @items );
ok($result eq 'TRUE', "with 'N/A' array elements");

# CONDITION: Array with mixed blank and 'N/A' as array elements 

my @items = ('N/A','','N/A','');
my $result = DBinterface::isArrayEmpty( @items );
ok($result eq 'TRUE', "with mixed blank and 'N/A' array elements");

# CONDITION: Array with one of the elements as valid

my @items = ('N/A','','N/A','Hello','' );
my $result = DBinterface::isArrayEmpty( @items );
ok($result eq 'FALSE',"with one of the elements as valid");

################################ TEST : 'querySeqDNA' ################################

print "\n************************** TEST: 'querySequence' **************************\n";

my $seq = DBinterface::querySequence('232322', 'ProteinSeq');
ok( $seq eq 'ERROR:DB_COLUMN_EMPTY',"with no sequence data");

my $seq = DBinterface::querySequence('AB002805', 'GeneSeq');
ok( length($seq), "with valid argument accession number 'AB002805'");


################################ TEST : 'buildCodingSeq' ################################

print "\n************************** TEST: 'buildCodingSeq' **************************\n";

my @seq = DBinterface::buildCodingSeq('AB002805');
ok( @seq, "with valid argument accession number 'AB002805'");


