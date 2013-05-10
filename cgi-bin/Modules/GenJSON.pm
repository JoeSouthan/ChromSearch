#! /usr/bin/perl -w
#
#   GenJSON.pm - Generates JSON
#   Written by: Joseph Southan
#   Date:       18/3/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      *See functions*
#   Requires:   JSON, ChromoDB, EnzCutter
#   Updated:    10/5/13
#
package GenJSON;
use strict;
use JSON;
use ChromoDB;
use EnzCutter;
use Exporter;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw ();

##############################################################################################################################
#   Function:       doSearch                                                                                                 #
#   Description:    Searches DB and returns JSON                                                                             #
#   Usage:          doSearch([Query - text], [GeneId, AccessionNumber, ChromosomeLocation, ProteinName])                     #
#   Returns:        JSON Data object                                                                                         #
########################################################################################################################################################
sub doSearch {
    my $json = JSON->new;
    my ($query,$type)= @_;
    unless (defined($query) or defined($type)) {
        error("Search: Parameters missing");
    } else {
        $query = Sanitise($query);
        $type = Sanitise($type);
        my %result = ChromoDB::GetSearchResults($query,$type,0);
        return $json->pretty->encode(\%result);
    }

}
###############################################################################################################################
#   Function:       doSingle                                                                                                  #
#   Description:    Returns a single Gene                                                                                     #
#   Usage:          doSingle([AccessionNumber])                                                                               #
#   Returns:        JSON Data object                                                                                          #
########################################################################################################################################################
sub doSingle {
    my $json = JSON->new;
    my ($query)= @_;
    unless (defined($query)) {
        error("Single: Query not defined");
    } else {
        $query = Sanitise($query);
        my $type = "AccessionNumber";
        my %result = ChromoDB::GetSearchResults($query,$type,2);
        #Format for FASTA
            my $DNAsequence = $result{$query}{"DNASeq"};
            my $AAsequence = $result{$query}{"AASeq"};
            #Break it into 70 character Chunks
            my @DNAmod = $DNAsequence =~ /(.{1,70})/g;
            my @AAmod = $AAsequence =~ /(.{1,70})/g;
            #Send it back
            my $geneName = $result{$query}{"GeneName"};
            my $pID = $result{$query}{"ProteinId"};
            my $name = $result{$query}{"ProteinName"};
            unshift (@DNAmod, ">gi|$geneName|gb|$pID|$name");
            unshift (@AAmod, ">gi|$geneName|gb|$pID|$name");
            $result{$query}{"DNASeqFASTA"} = \@DNAmod;
            $result{$query}{"AASeqFASTA"} = \@AAmod;
        #Break sequence into different parts
            my @featsWithSeqs; 
            my @seq_feats = qw (NCS;0:262 INTRON;290:300 EXON;301:352);

           # my @seq_feats = @{$result{$query}{"SeqFeat"}};
            if (@seq_feats){
                foreach my $feats (@seq_feats) {
                    if ($feats =~ /(\w+)\;(\d*)\:(\d*)/) {
                        my $ext_seq = substr($DNAsequence, $2, $3-$2);
                        push (@featsWithSeqs, "$1|$ext_seq");
                    }
                }
                $result{$query}{"FeatureSequences"} = \@featsWithSeqs;
            }
        return $json->pretty->encode(\%result);
    }

}
###############################################################################################################################
#   Function:       doBrowse                                                                                                  #
#   Description:    Returns a search on a single letter                                                                       #
#   Usage:          doBrowse([a-z A-Z])                                                                                       #
#   Returns:        JSON Data object                                                                                          #
########################################################################################################################################################
sub doBrowse {
    my $json = JSON->new;
    my ($query)= @_;
    unless (defined ($query)) {
        error("Browse: No query defined");
    } else {
        $query = Sanitise($query);
        my $type = "AccessionNumber";
        my %result = ChromoDB::GetSearchResults($query,$type,1);
        return $json->pretty->encode(\%result);
    }

}
###############################################################################################################################
#   Function:       getRes                                                                                                    #
#   Description:    Returns stored restriction sites                                                                          #
#   Usage:          getRes()                                                                                                  #
#   Returns:        JSON Data object                                                                                          #
########################################################################################################################################################
sub getRes {
    my $json = JSON->new;
    my %result = ChromoDB::GetRES();
    return $json->pretty->encode(\%result);
}
###############################################################################################################################
#   Function:       CalcRES                                                                                                   #
#   Description:    Cleave an enzyme enzymatically                                                                            #
#   Usage:          CalcRES([Accession or FASTA or Sequence], [Comma separated list of enzymes or A|TTTT])                    #
#   Returns:        JSON Data object                                                                                          #
########################################################################################################################################################
sub CalcRES {
    my $json = JSON->new;
    my ($query, $enz) = @_;
    unless (defined($query) or defined($enz)) {
        error("CalcRES: Not enough queries");
    } else {
        #Remove %2C's 
        $query = Sanitise($query);
        $enz = Sanitise($enz);
        $enz =~s/%2C/\,/g;
        my %result = EnzCutter::doCut($query,$enz); 
        return $json->pretty->encode(\%result);
    }

}
###############################################################################################################################
#   Function:       Sanitise                                                                                                  #
#   Description:    Removes unwanted characters                                                                               #
#   Usage:          Sanitise([String])                                                                                        #
#   Returns:        String                                                                                                    #
########################################################################################################################################################
sub Sanitise {
    my $input = $_[0];
    $input =~ s/[^a-zA-Z0-9\|\.\"\,\']//g;
    return $input;
}
###############################################################################################################################
#   Function:       error                                                                                                     #
#   Description:    Returns an error as JSON                                                                                  #
#   Usage:          doSingle([String])                                                                                        #
#   Returns:        JSON Data object                                                                                          #
########################################################################################################################################################
sub error {
    my $json = JSON->new;
    my %error = (
        "error" => "$_[0]"
    );
    return $json->pretty->encode(\%error);
}
1;
