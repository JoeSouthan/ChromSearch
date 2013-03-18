#! /usr/bin/perl 

use strict;
use Test::Simple tests => 23;
use DBinterface;

################################ TEST: 'databaseConnect'###############################

print "\n************************** TEST : 'databaseConnect' **************************\n";

# CONDITION: Just run function
my $dbhandle = DBinterface::databaseConnect();
ok( $dbhandle ne undef,'Test DB connection' );


################################ TEST: 'queryRun'###############################

print "\n************************** TEST : 'queryRun' **************************\n";


# CONDITION: Valid string 'SELECT geneId FROM gene WHERE geneId='2780780'

my $sqlQuery = "SELECT geneID FROM gene WHERE geneId='2780780'";
my @queryData = DBinterface::queryRun($sqlQuery);
ok(@queryData, "Testing 'queryRun' with valid string 'SELECT geneId FROM gene WHERE 
geneId = '2780780'");

# CONDITION: Valid string 'SELECT geneId FROM gene'

my $sqlQuery = "SELECT geneId FROM gene";
my @queryData = DBinterface::queryRun($sqlQuery);
ok(@queryData, "Testing 'queryRun' with valid string for many rows");


################################ TEST: 'queryColumn'###############################

print "\n************************** TEST : 'queryColumn' **************************\n";

# CONDITION: Valid function arguments

my @id = DBinterface::queryColumn('geneId');
ok( @id, "Testing 'queryColumn' with geneId as argument" );
#print $id,"\n";
foreach my $entry (@id){
	#print $entry,"\n";
}

my @id = DBinterface::queryColumn('accessionNo');
ok( @id, "Testing 'queryColumn' with accessionNo as argument" );
#print $id,"\n";
foreach my $entry (@id){
	#print $entry,"\n";
}

my @id = DBinterface::queryColumn('proteinName');
ok( @id, "Testing 'queryColumn' with proteinName as argument" );
foreach my $entry (@id){
	#print $entry,"\n";
}

################################ TEST 'querySearch' ###############################

print "\n************************** TEST: 'querySearch' **************************\n";

# CONDITION: Valid parameters for geneId

my @results = DBinterface::querySearch("2780780","geneId");
ok(@results[0] eq 'AB002805:2780780', 
"with valid parameters '2780780' as search string and 'geneId' as identifier type" );
foreach my $entry (@results){
	#print $entry,"\n";
}

# CONDITION: Valid parameters for proteinName

my @results = DBinterface::querySearch("DUSP6","proteinName");
ok( @results[0] eq 'AB013601:60683881', 
"with valid parameters 'DUSP1' as search string and 'proteinName' as type");
foreach my $entry (@results){
	#print $entry,"\n";
}

# CONDITION: Valid parameters for Accession number

my @results = DBinterface::querySearch("AB002805","accessionNo");
ok( @results[0] eq 'AB002805:2780780',
"with valid parameters 'AB002805' as search string and 'accessionNo' as type");
foreach my $entry (@results){
	#print $entry,"\n";
}

# CONDITION: Valid parameters for chromosome location

my @results = DBinterface::querySearch("12q13","chromLoc");
ok( length(@results),
"with valid parameters '12q13' as search string and 'chromLoc' as type" );
foreach my $entry (@results){
	#print $entry,"\n";
}
	
# CONDITION: Valid parameters but not in DB

my $results = DBinterface::querySearch("HEX5","proteinName");
ok( $results eq 'ERROR:NO_DB_MATCHES',"Testing 'querySearch' with valid parameters but not in DB");

################################ TEST 'getIdentifier' ###############################

print "\n************************** TEST: 'getIdentifier' **************************\n";

# CONDITION: Valid parameters

my $identifier = DBinterface::getIdentifier("GeneID");
ok($identifier eq 'geneId', "with valid parameter 'GeneID'");

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
#print $seq,"\n";

################################ TEST : 'buildCodingSeq' ################################

print "\n************************** TEST: 'buildCodingSeq' **************************\n";

my @seq = DBinterface::buildCodingSeq('AB002805');
ok( @seq, "with valid argument accession number 'AB002805' with one exon");
foreach my $entry (@seq){
	print $entry,"\n";
}

@seq = DBinterface::buildCodingSeq('AB005990');
ok( @seq, "with valid argument accession number 'AB005990' with more than one exon");
foreach my $entry (@seq){
	print $entry,"\n";
}

# PRODUCES  A BUG returns -1 on the last NCS
@seq = DBinterface::buildCodingSeq('GU994024');
ok( @seq, "with valid argument accession number 'GU994024' with more than one exon");
foreach my $entry (@seq){
	print $entry,"\n";
}





