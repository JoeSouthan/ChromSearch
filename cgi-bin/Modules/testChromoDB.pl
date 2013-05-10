#!/usr/bin/perl

###########################################################################################################
#
#	testChromoDB.pl - Functional tests for all functions contained in ChromoDB.pm
#	Author: Sam Coulson
#
###########################################################################################################

use Test::Simple tests => 44;
use Data::Dumper;
use strict;
use warnings;

use ChromoDB;

################################ TEST: 'GetSearchResults' ################################

# TEST 'GetSearchResults'
print "************************** TEST : 'GetSearchResults' **************************\n";

# CONDITION: No parameters
{
	my %results = GetSearchResults('','',0);
	ok( $results{'error'} eq 'ERROR:ZERO_LENGTH_ARGUMENT', "with no parameters");
	#print Dumper(%results);
}

# CONDITION: Invalid identifier
{
	my %results = GetSearchResults('2780780','geneid',0);
	ok( $results{'error'} eq 'ERROR:UNRECOGNIZED_ID', "invalid identifier");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of 2780780 (assumes this dummy data is in DB) and GeneID
{
	my %results = GetSearchResults('2780780','GeneID',0);
	ok( %results, "with '2780780' and 'GeneID' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of DUSP6 (assumes this dummy data is in DB) and ProteinProduct
{
	my %results = GetSearchResults('DUSP6','ProteinProduct',0);
	ok( %results, "with 'DUSP6' and 'ProteinProduct' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of AB002805 (assumes this dummy data is in DB) and AccessionNumber
{
	my %results = GetSearchResults('AB002805','AccessionNumber',0);
	ok( %results, "with '2780780' and 'AccessionNumber' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct parameters of q13 (assumes this dummy data is in DB) and ChromosomeLocation
{
	my %results = GetSearchResults('q13','ChromosomeLocation',0);
	ok( %results, "with 'q13' and 'ChromosomeLocation' as parameters");
	#print Dumper(%results);
}

# CONDITION: Correct agrument but AccessionNumber not in DB
{
	my %results = GetSearchResults('AB0000000','AccessionNumber',0);
	ok( $results{'error'} eq 'DB_RETURNED_NO_MATCHES', "with invalid AccessionNumber argument");
	#print Dumper(%results);
}

# CONDITION Partial words in search string.
{
	my %results = GetSearchResults('AB00','AccessionNumber',0);
	ok( %results, "with partial AccessionNumber argument");
	#print Dumper(%results);
}

# CONDITION With single letter for browse mode.
{
	my %results = GetSearchResults('A','ProteinProduct',1);
	ok( %results, "with single letter for browse mode");
	#print Dumper(%results);
}

# CONDITION With return everything mode on i.e. 2.
#{
	#my %results = GetSearchResults('AB002805','AccessionNumber',2);
	#ok( %results, "with return everything mode on");
	#print Dumper(%results);
#}

# CONDITION With return everything mode on i.e. 2.
{
	my %results = GetSearchResults('AC048352','AccessionNumber',2);
	ok( %results, "with return everything mode on");
	#print Dumper(%results);
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

################################ TEST: 'DatabaseConnect'###############################

print "\n************************** TEST : 'DatabaseConnect' **************************\n";

# CONDITION: Just run function
{
	my $dbhandle = DatabaseConnect();
	ok( $dbhandle, 'Test DB connection' );
}

################################ TEST 'GetIdentifier' ###############################

print "\n************************** TEST: 'GetIdentifier' **************************\n";

# CONDITION: Valid parameters
{
	my $identifier = GetIdentifier("GeneID");
	ok($identifier eq 'geneId', "with valid parameter 'GeneID'");
}

# CONDITION: Incorrect parameters
{
	my $identifier = GetIdentifier("geneindentifier");
	ok( !defined($identifier), "with incorrect parameter 'geneidentifier'");
}

################################ TEST: 'DoQuery'###############################

print "\n************************** TEST : 'DoQuery' **************************\n";


# CONDITION: Valid string 'SELECT geneId FROM gene WHERE geneId='2780780'
{
	my $sqlQuery = "SELECT geneID FROM gene WHERE geneId='2780780'";
	my @queryData = DoQuery( $sqlQuery );
	ok( $queryData[0]->[0] == 2780780, "Testing 'DoQuery'' with valid string 'SELECT geneId FROM gene WHERE 
	geneId = '2780780'" );
	#print Dumper(@queryData);
}

# CONDITION: Valid string 'SELECT geneId FROM gene'
{
	my $sqlQuery = "SELECT geneId FROM gene";
	my @queryData = DoQuery( $sqlQuery );
	ok(@queryData, "Testing 'DoQuery' with valid string for single column with many rows");
	#print Dumper(@queryData);
}

# CONDITION: Valid string with multiple columns 'SELECT accessionNo, geneId FROM gene'
{
	my $sqlQuery = "SELECT accessionNo, geneId FROM gene";
	my @queryData = DoQuery( $sqlQuery );
	ok( @queryData, "Testing 'DoQuery' with multiple columns" );
	#print Dumper(@queryData);
}
################################ TEST 'QuerySearch' ###############################

print "\n************************** TEST: 'QuerySearch' **************************\n";

# CONDITION: Valid parameters for geneId
{
	my @results = QuerySearch('2780780','geneId',0);
	ok(@results, "with valid parameters '2780780' as search string and 'geneId' as identifier type" );
	#print Dumper( @results );
}

# CONDITION: Valid parameters for proteinName
{
	my @results = QuerySearch('DUSP6','proteinName',0);
	ok( @results, "with valid parameters 'DUSP1' as search string and 'proteinName' as type");
	#print Dumper( @results );
}

# CONDITION: Valid parameters for accessionNo
{
	my @results = QuerySearch('AB002805','accessionNo',0);
	ok( @results, "with valid parameters 'AB002805' as search string and 'accessionNo' as type");
	#print Dumper( @results );
}

# CONDITION: Valid parameters for chromosome location
{
	my @results = QuerySearch('12q13','chromLoc',0);
	ok( @results, "with valid parameters '12q13' as search string and 'chromLoc' as type" );
	#print Dumper( @results );
}
	
# CONDITION: Valid parameters but not in DB
{
	my @results = QuerySearch('HEX5','proteinName',0);
	ok( @results, "with valid parameters but not in DB");
	print Dumper( @results );
}
# CONDITION: Valid arguments but only partial name
{
	my @results = QuerySearch('AB00','accessionNo',0);
	ok( @results, "with valid arguments but only partial name");
	#print Dumper( @results );
}

# CONDITION: Valid arguments in browse mode
{
	my @results = QuerySearch('A','proteinName',1);
	ok( @results, "with valid arguments in browse mode");
	#print Dumper( @results );
}

################################ TEST : 'IsArrayEmpty' ################################ 

print "\n************************** TEST: 'IsArrayEmpty' **************************\n";

# CONDITION: 2D array with items in
{
	my @items = ( ["one","two","three"], ["four","five","six"] );
	my $result = IsArrayEmpty( @items );
	ok($result eq '1', "with valid filled out array" );
}

# CONDITION: 2d array with blank entries
{
	my @items = (['','','',''], ['','',''], ['','','']);
	my $result = IsArrayEmpty( @items );
	ok($result eq '0', "with blank array elements");
}

# CONDITION: 2d array with 'N/A' as array elements 
{
	my @items = (['N/A','N/A','N/A','N/A'], ['N/A','N/A','N/A','N/A']);
	my $result = IsArrayEmpty( @items );
	ok($result eq '0', "with 'N/A' array elements");
}

# CONDITION: Array with mixed blank and 'N/A' as array elements 
{
	my @items = (['N/A','','N/A',''], ['N/A','','N/A','']);
	my $result = IsArrayEmpty( @items );
	ok($result eq '0', "with mixed blank and 'N/A' array elements");
}

# CONDITION: Array with one of the elements as valid
{
	my @items = (['N/A','','N/A','ValidElement',''], ['N/A','','N/A','N/A',''] );
	my $result = IsArrayEmpty( @items );
	ok($result eq '1',"with one of the elements as valid");
}

################################ TEST : 'BuildCodingSeq' ################################

print "\n************************** TEST: 'BuildCodingSeq' **************************\n";

# CONDITION: With valid accession number 
{
	my @seq = BuildCodingSeq('AB002805');
	ok( @seq, "with valid argument accession number 'AB002805' with one exon not starting at position 1");
	print Dumper(@seq);
}

# CONDITION: With valid accession number that has more than one exon
{
	my @seq = BuildCodingSeq('AB005990');
	ok( @seq, "with valid argument accession number 'AB005990' with more than one exon");
	print Dumper(@seq);
}

# CONDITION: With valid argument accession number that has more than one exon
{
	my @seq = BuildCodingSeq('GU994024');
	ok( @seq, "with valid argument accession number 'GU994024' with more than one exon");
	print Dumper(@seq);
}

# CONDITION: Has many exons, checking for consistency in output
{
	my @seq = BuildCodingSeq('U29700');
	ok( @seq, "With 'U29700' as accession, has many exons, chekcing for consistency in output  ");
	print Dumper(@seq);
}

# CONDITION: Has many exons, chekcing for consistency in output
{
	my @seq = BuildCodingSeq('AY496854');
	ok( @seq, "With 'AY496854' as accession, has many exons, chekcing for consistency in output  ");
	print Dumper(@seq);
}

################################ TEST: 'GetCodons' ################################

# TEST 'GetCodons'
print "************************** TEST : 'GetCodons' **************************\n";

# CONDITION: Valid accession number
{
	my %Codons = GetCodons('AB002805');
	ok( %Codons, "with valid accession number");
	#print Dumper(@Codons);
}

# CONDITION: Valid accession number with no codons
{
	my %Codons = GetCodons('AC048352');
	ok( %Codons, "with valid accession number with no codons");
	#print Dumper(@Codons);
}

# CONDITION: Special case for the whole chromosome
{
	my %Codons = GetCodons('Chrom_12');
	ok( %Codons, "with accession for whole of chromosome 12");
	#print Dumper(@Codons);
}

################################ TEST : 'Set/Get error messages' ################################


print "\n************************** TEST: 'Set/Get error messages' **************************\n";
{
	SetLastErrorMessage('NO_DATA');
	my $errorMessage = GetLastErrorMessage();
	ok( $errorMessage eq 'NO_DATA', "get last error message");
}

################################ TEST: 'FindRES' ################################

# TEST 'FindRES'
print "************************** TEST : 'FindRES' **************************\n";

# CONDITION: No aguments, none necessary
{
	my @RESInfo = FindRES();
	ok( @RESInfo, "no arguments by default");
	#print Dumper(@RESInfo);
}

################################ TEST : 'QuerySequence' ################################

print "\n************************** TEST: 'QuerySequence' **************************\n";

# CONDITION: valid entry with no sequence data
{
	my $seq = QuerySequence('232322', 'ProteinSeq');
	ok( !defined($seq) ,"with no sequence data");
}

# CONDITION: valid entry with sequence data
{
	my $seq = QuerySequence('AB002805', 'GeneSeq');
	ok( $seq, "with valid argument accession number 'AB002805'");
	#print $seq,"\n";
}

# CONDITION: valid entry with sequence data that is in complement form
{
	my $seq = QuerySequence('AF416705', 'GeneSeq');
	ok( $seq, "with valid argument accession number 'AF416705' that is a compliment sequence");
	#print $seq,"\n";
}


################################ TEST: 'CalculateCodonUsage' ################################

# TEST 'CalculateCodonUsage'
print "************************** TEST : 'CalculateCodonUsage' **************************\n";

# CONDITION: With valid accession number as argument 
{
	my %codonData = CalculateCodonUsage('AB002805');
	ok( %codonData, "with valid accession number");
	#print Dumper(%codonData);
}

# CONDITION: With valid accession number as argument but no codons 
{
	my %codonData = CalculateCodonUsage('AC048352');
	ok( %codonData, "with valid accession number but no codons");
	#print Dumper(%codonData);
}

