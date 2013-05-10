#! /usr/bin/perl -w
#
#   enz_cutter.pl - Cuts a sequence
#   Written by: Joseph Southan
#   Date:       6/2/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      None
#   Requires:   GenJSON, WebHTML, EnzCutter, GenJSON, JSON, Test::Simple
#   Updated:    10/5/13
#
use strict;
use JSON;

use lib '../Modules';
use GenJSON;
use CodonImager;
use EnzCutter;
use Data::Dumper;
use Test::Simple tests => 20;


#GenJSON tests

my $enzymes = "EcoRI,BamHI,BsuMI";
#doSearch doSingle doBrowse getRES CalcRES error
print "\nGenJSON Tests \n";
GenJSON_t_doSearch();
GenJSON_t_doSingle();
GenJSON_t_san();

print "\nEnzCutter Tests \n";
EnzCutter_t_doCut();
EnzCutter_t_revSeq();


sub GenJSON_t_san {
    print "\nSanitise\n";
    my $san = GenJSON::Sanitise("Te\$\$st\|\"\'\.\,\$\£");
    ok($san eq "Test|\"\'\.\,", "String sanitised");
}
sub GenJSON_t_doSearch {
    my $json = new JSON;
    my $result = GenJSON::doSearch("AF164120","AccessionNumber");
    my $json_decode = $json->decode($result);

    print "\ndoSearch - Expected\n\n";
        ok (ref($json_decode->{AF164120}) eq "HASH", "Hash returned" );
        ok ($json_decode->{AF164120}->{GeneName} eq "5726484", "GeneName - 5726484" );
        ok ($json_decode->{AF164120}->{GeneLength} eq "345", "GeneLength - 345" );
        ok ($json_decode->{AF164120}->{ChromosomeLocation} eq "12q24.2", "ChromosomeLocation - 12q24.2" );
        ok ($json_decode->{AF164120}->{ProteinId} eq "AAD48447.1", "ProteinId - AAD48447.1" );
        ok (ref($json_decode->{AF164120}->{SeqFeat}) eq "ARRAY", "SeqFeat - Valid Array" );
        ok ($json_decode->{AF164120}->{ProteinName} eq "mitochondrial aldehyde dehydrogenase 2", "ProteinName - \"mitochondrial aldehyde dehydrogenase 2\"" );

    print "\ndoSearch - Bad tests\n\n";
        my $result_fail = GenJSON::doSearch("AF164120", "GeneId");
        my $json_decode_fail = $json->decode($result_fail);
        ok ($json_decode_fail->{error} eq "ERROR:UNRECOGNIZED_ID", "Bad id \"GeneID\" passed, error returned");
        my $result_fail_1 = GenJSON::doSearch();
        my $json_decode_fail_1 = $json->decode($result_fail_1);
        ok ($json_decode_fail_1->{error} eq "Search: Parameters missing", "Bad Parameters");
    print "####\n";
}
sub GenJSON_t_doSingle {
    my $json = new JSON;
    my $result = GenJSON::doSingle("AF164120");
    my $json_decode = $json->decode($result);

    print "\ndoSingle - Expected\n\n";
        ok(ref($json_decode->{AF164120}->{CodonUsage}) eq "HASH", "CodonUsage - Hash obtained");
        ok(ref($json_decode->{AF164120}->{DNASeqFASTA}) eq "ARRAY", "DNASeqFASTA - Array obtained");
        ok(ref($json_decode->{AF164120}->{AASeqFASTA}) eq "ARRAY", "AASeqFASTA - Array obtained");
        ok($json_decode->{AF164120}->{AASeqFASTA}[0] eq ">gi|5726484|gb|AAD48447.1|mitochondrial aldehyde dehydrogenase 2", "Correct AASeqFASTA format");
        ok($json_decode->{AF164120}->{DNASeqFASTA}[0] eq ">gi|5726484|gb|AAD48447.1|mitochondrial aldehyde dehydrogenase 2", "Correct DNASeqFASTA format");
}

sub EnzCutter_t_doCut {
    print "\n\nEnzCutter - doCut\n";
    my %t1 = EnzCutter::doCut("ATTTT", "AA|AA");
    ok ($t1{"result"}{"AA|AA"}{"error"} eq  "No Cuts", "Correct Cut");

    my %t2 = EnzCutter::doCut("ATTTT", "|AAAA");
    ok ($t2{"result"}{"|AAAA"}{"error"} eq "EnzCutter: Incorrect Cut format", "Bad cut detected");
    
    my %t3 = EnzCutter::doCut("ATTTT", "at|Ta");
    ok ($t3{"result"}{"AT|TA"}{"error"} eq "No Cuts", "Mixed caps corrected");

    my %t4 = EnzCutter::doCut("ATTTT", "A|TT");
    ok ($t4{"result"}{"A|TT"}{"cut1"}{"location"} eq "1,4", "Correct Cut, good results");
}
sub EnzCutter_t_revSeq {
    my ($before, $mid , $after, $index) = ("AAAA", "TTTT", "GGGG", 3);
    my $result = EnzCutter::reverseSeq($before,$mid,$after,$index);
    ok ($result eq "TTTT,A|AAA,CCCC", "Sequence reversed correctly");
}
