#! /usr/bin/perl 

use strict;
use warnings;
use Data::Dumper;

use Test::Simple tests => 31;
use DBinterface;

################################ TEST: 'databaseConnect'###############################

print "\n************************** TEST : 'databaseConnect' **************************\n";

# CONDITION: Just run function
{
	my $dbhandle = DBinterface::databaseConnect();
	ok( $dbhandle, 'Test DB connection' );
}

################################ TEST: 'DoQuery'###############################

print "\n************************** TEST : 'DoQuery' **************************\n";


# CONDITION: Valid string 'SELECT geneId FROM gene WHERE geneId='2780780'
{
	my $sqlQuery = "SELECT geneID FROM gene WHERE geneId='2780780'";
	my @queryData = DBinterface::DoQuery( $sqlQuery );
	ok( $queryData[0]->[0] == 2780780, "Testing 'DoQuery'' with valid string 'SELECT geneId FROM gene WHERE 
	geneId = '2780780'" );
}

# CONDITION: Valid string 'SELECT geneId FROM gene'
{
	my $sqlQuery = "SELECT geneId FROM gene";
	my @queryData = DBinterface::DoQuery( $sqlQuery );
	ok(@queryData, "Testing 'DoQuery' with valid string for single column with many rows");
	#print Dumper(@queryData);
}

# CONDITION: Valid string with multiple columns 'SELECT accessionNo, geneId FROM gene'
{
	my $sqlQuery = "SELECT accessionNo, geneId FROM gene";
	my @queryData = DBinterface::DoQuery( $sqlQuery );
	ok( @queryData, "Testing 'DoQuery' with multiple columns" );
	#print Dumper(@queryData);
}

################################ TEST: 'QueryColumn'###############################

print "\n************************** TEST : 'QueryColumn' **************************\n";

# CONDITION: geneId as argument
{
	my @columnData = DBinterface::QueryColumn( 'geneId' );
	ok( @columnData, "Testing 'queryColumn' with geneId as argument" );
	#print Dumper( @columnData );
}

# CONDITION: accessionNo as argument
{
	my @columnData = DBinterface::QueryColumn( 'accessionNo' );
	ok( @columnData, "Testing 'queryColumn' with accessionNo as argument" );
	#print Dumper( @columnData );
}

# CONDITION: proteinName as argument
{
	my @columnData = DBinterface::QueryColumn( 'proteinName' );
	ok( @columnData, "Testing 'queryColumn' with proteinName as argument" );
	#print Dumper( @columnData );
}

################################ TEST 'QuerySearch' ###############################

print "\n************************** TEST: 'QuerySearch' **************************\n";

# CONDITION: Valid parameters for geneId
{
	my @results = DBinterface::QuerySearch("2780780","geneId");
	ok(@results, "with valid parameters '2780780' as search string and 'geneId' as identifier type" );
	#print Dumper( @results );
}

# CONDITION: Valid parameters for proteinName
{
	my @results = DBinterface::QuerySearch("DUSP6","proteinName");
	ok( @results, "with valid parameters 'DUSP1' as search string and 'proteinName' as type");
	#print Dumper( @results );
}

# CONDITION: Valid parameters for accessionNo
{
	my @results = DBinterface::QuerySearch("AB002805","accessionNo");
	ok( @results, "with valid parameters 'AB002805' as search string and 'accessionNo' as type");
	#print Dumper( @results );
}

# CONDITION: Valid parameters for chromosome location
{
	my @results = DBinterface::QuerySearch("12q13","chromLoc");
	ok( @results, "with valid parameters '12q13' as search string and 'chromLoc' as type" );
	#print Dumper( @results );
}
	
# CONDITION: Valid parameters but not in DB
{
	my @results = DBinterface::QuerySearch("HEX5","proteinName");
	ok( @results, "Testing 'querySearch' with valid parameters but not in DB");
	#print Dumper( @results );
}
################################ TEST 'getIdentifier' ###############################

print "\n************************** TEST: 'getIdentifier' **************************\n";

# CONDITION: Valid parameters
{
	my $identifier = DBinterface::GetIdentifier("GeneID");
	ok($identifier eq 'geneId', "with valid parameter 'GeneID'");
}

# CONDITION: Incorrect parameters
{
	my $identifier = DBinterface::GetIdentifier("geneindentifier");
	ok( !defined($identifier), "with incorrect parameter 'geneidentifier'");
}
################################ TEST : 'IsArrayEmpty' ################################ 

print "\n************************** TEST: 'IsArrayEmpty' **************************\n";

# CONDITION: 2D array with items in
{
	my @items = ( ["one","two","three"], ["four","five","six"] );
	my $result = DBinterface::IsArrayEmpty( @items );
	ok($result eq '1', "with valid filled out array" );
}

# CONDITION: 2d array with blank entries
{
	my @items = (['','','',''], ['','',''], ['','','']);
	my $result = DBinterface::IsArrayEmpty( @items );
	ok($result eq '0', "with blank array elements");
}

# CONDITION: 2d array with 'N/A' as array elements 
{
	my @items = (['N/A','N/A','N/A','N/A'], ['N/A','N/A','N/A','N/A']);
	my $result = DBinterface::IsArrayEmpty( @items );
	ok($result eq '0', "with 'N/A' array elements");
}

# CONDITION: Array with mixed blank and 'N/A' as array elements 
{
	my @items = (['N/A','','N/A',''], ['N/A','','N/A','']);
	my $result = DBinterface::IsArrayEmpty( @items );
	ok($result eq '0', "with mixed blank and 'N/A' array elements");
}

# CONDITION: Array with one of the elements as valid
{
	my @items = (['N/A','','N/A','ValidElement',''], ['N/A','','N/A','N/A',''] );
	my $result = DBinterface::IsArrayEmpty( @items );
	ok($result eq '1',"with one of the elements as valid");
}

################################ TEST : 'QuerySequence' ################################

print "\n************************** TEST: 'QuerySequence' **************************\n";

# CONDITION: valid entry with no sequence data
{
	my $seq = DBinterface::QuerySequence('232322', 'ProteinSeq');
	ok( !defined($seq) ,"with no sequence data");
}

# CONDITION: valid entry with sequence data
{
	my $seq = DBinterface::QuerySequence('AB002805', 'GeneSeq');
	ok( $seq, "with valid argument accession number 'AB002805'");
	#print $seq,"\n";
}

################################ TEST : 'BuildCodingSeq' ################################

print "\n************************** TEST: 'BuildCodingSeq' **************************\n";

{
	my @seq = DBinterface::BuildCodingSeq('AB002805');
	ok( @seq, "with valid argument accession number 'AB002805' with one exon");
	#print Dumper(@seq);
}


{
	my @seq = DBinterface::BuildCodingSeq('AB005990');
	ok( @seq, "with valid argument accession number 'AB005990' with more than one exon");
	#print Dumper(@seq);
}


{
	my @seq = DBinterface::BuildCodingSeq('GU994024');
	ok( @seq, "with valid argument accession number 'GU994024' with more than one exon");
	#print Dumper(@seq);
}

################################ TEST : 'Set/Get error messages' ################################


print "\n************************** TEST: 'Set/Get error messages' **************************\n";

DBinterface::SetLastErrorMessage('NO_DATA');
my $errorMessage = DBinterface::GetLastErrorMessage();
ok( $errorMessage eq 'NO_DATA', "get last error message");


################################ TEST: 'BuildSummaryData' ################################

# TEST 'BuildSummaryData'
print "************************** TEST : 'BuildSummaryData' **************************\n";

# CONDITION: With valid accession number as argument 
{
	my %data = DBinterface::BuildSummaryData('AB002805');
	ok( %data, "with valid accession number AB002805 as an argument");
	#print Dumper(%data);
}

################################ TEST: 'FindRES' ################################

# TEST 'FindRES'
print "************************** TEST : 'FindRES' **************************\n";

# CONDITION: No aguments, none necessary
{
	my @RESInfo = DBinterface::FindRES();
	ok( @RESInfo, "no arguments by default");
	#print Dumper(@RESInfo);
}

################################ TEST: 'GetCodons' ################################

# TEST 'GetCodons'
print "************************** TEST : 'GetCodons' **************************\n";

# CONDITION: No aguments, none necessary
{
	my @Codons = DBinterface::GetCodons('AB002805');
	ok( @Codons, "with valid accession number");
	#print Dumper(@Codons);
}

# CONDITION: Special case for the whole chromosome
{
	my @Codons = DBinterface::GetCodons('Chrom_12');
	ok( @Codons, "with accession for whole of chromosome 12");
	#print Dumper(@Codons);
}

################################ TEST: 'CalculateCodonUsage' ################################

# TEST 'CalculateCodonUsage'
print "************************** TEST : 'CalculateCodonUsage' **************************\n";

# CONDITION: With valid accession number as argument 
{
	my @Codons = DBinterface::GetCodons('AB002805');
	my %codonData = DBinterface::CalculateCodonUsage(@Codons);
	ok( %codonData, "with valid accession number");
	#print Dumper(%codonData);
}

# CONDITION: With codons for whole chromosome  
{
	my @Codons = DBinterface::GetCodons('Chrom_12');
	my %codonData = DBinterface::CalculateCodonUsage(@Codons);
	ok( %codonData, "with accession for whole chromosome");
	#print Dumper(%codonData);
}

