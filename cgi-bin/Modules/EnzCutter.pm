#! /usr/bin/perl -w
#
#   EnzCutter.pm - Cleaves a sequence
#   Written by: Joseph Southan
#   Date:       15/2/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      *See Functions*
#   Requires:   ChromoDB
#   Updated:    10/5/13
#
package EnzCutter;
use strict;
use ChromoDB;
use Exporter;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw ();


###############################################################################################################################
#   Function:       doCut                                                                                                     #
#   Description:    Cuts a sequence enzymatically                                                                             #
#   Usage:          doCut([sequence/Accession],[Comma separated list of Restriction enzymes or in the format of A|AAAAA])     #
#   Returns:        A hash of hashes containing the cuts and their locations                                                  #
########################################################################################################################################################
sub doCut { 
    my (%result,$sequence, $gene_length);

    #Get Current res
    my %currentRES = ChromoDB::GetRES();

    #Split up the enzyme choices
    my @enz = split /[,]/, $_[1];
    my $query = $_[0];

    if ($query =~/^\w{1,4}\d{1,6}/i){
        #Its a known gene
        #Get it's sequence
        my %search = ChromoDB::GetSearchResults($query,"AccessionNumber", 2);
        $sequence = $search{$query}{"DNASeq"};
    } elsif ($query =~/(>.*)/g) {
        #It's a FASTA sequence
        #Get rid of the FASTA line and compress
        my @temp_array = split("\r\n", $query);
        for (my $i = 0; $i < @temp_array; $i++) {
            if (length($temp_array[$i]) < 1) {
                delete $temp_array[$i];
            } elsif ($temp_array[$i] =~ /^>/) {
                delete $temp_array[$i];
            }
        }
        $sequence = join("", @temp_array);
        $sequence = Sanitise($sequence);
    } elsif ($query =~/\d+?/g) {
        #The user has entered numbers
        $result{"result"}{"error"} = {"error" => "Numbers detected"};
        return %result;
    } else {
        #Its a pasted sequence
        #Flattening the sequence just in case
        my @temp_array = split("\r\n", $query);
        for (my $i = 0; $i < @temp_array; $i++) {
            if (length($temp_array[$i]) < 1) {
                delete $temp_array[$i];
            } 
        }
        $sequence = join("",@temp_array);
        $sequence = Sanitise($sequence);
    }
    #Process the sequence
    foreach my $enzymes (@enz) {
        #Get the cutsite
        my ($cutsite,%cutresult,$cutindex);
        if ($enzymes=~/[|]/) {
            #For custom cut sites
            #Make sure it's correct
            if ($enzymes =~ /^\|/){ 
                my %error = ("error" => "EnzCutter: Incorrect Cut format");
                $result{"result"}{$enzymes} = \%error;
                return %result;
            } else {
                #Make it upper case
                $enzymes =~ s/(.*)/uc($1)/eg;
                $cutsite = $enzymes;
            }
        } else {
            $cutsite = $currentRES{$enzymes};
        }
        #Remove the |
        my $cutsitemodified = $cutsite;
        #Find it's index
        $cutindex = index($cutsite, "|");
        $cutsitemodified =~ s/[|]//;

        my $count = 1;
        my $cutsite_length = length($cutsitemodified);
        $gene_length = length($sequence);
        

        #Do the matches and push to @matches
        for (my $i = 0; $i < $gene_length; $i++) {
            my %info;
            my $position = substr($sequence, $i, $cutsite_length);
            my $remaining_characters = $gene_length-$i;

            if ($position eq $cutsitemodified){
                my ($current_seq, $cutsite_after, $start, $after );
                unless ($cutsite_length >= $i) {
                    #Rewind substr to get some sequence data
                    $current_seq = substr($sequence, $i-$cutsite_length, ($cutsite_length*3));
                    $start = substr($current_seq, 0, $cutsite_length);
                    $after = substr($current_seq, ($cutsite_length*2), $cutsite_length);
                } else {
                    #Rewind substr
                    $current_seq = substr($sequence, 0, $cutsite_length+6);
                    $start = "";
                    $after = substr($current_seq, $cutsite_length, $cutsite_length);
                }
                #Reverse the sequence
                my $seqrev = reverseSeq($start,$cutsitemodified,$after,$cutindex);
                
                #Collect useful info
                $info{"cut"} = $cutsite;
                $info{"location"} = ($i+1).",".(($i+1)+$cutsite_length);
                $info{"sequence-forward"} = "$start,$cutsite,$after";
                $info{"sequence-reverse"} = $seqrev;
                $cutresult{"cut".$count} = \%info;
                $count++;
            }
        }
        #Error Handling
        unless (%cutresult) {
            $result{"result"}{$enzymes}{"result"} = "No cuts";
        } else {
            $result{"result"}{$enzymes} = \%cutresult;
        }
    }
    #Debug
    #print Dumper %result;
    return %result;
}
#######################################################################################
#   Function:       reverseSeq                                                        #
#   Description:    Reverses a sequence                                               #
#   Usage:          reverseSeq([String],[$string],[$string],[$Offset interger])       #
#   Returns:        A string with a reversed sequence                                 #
########################################################################################################################################################
sub reverseSeq {
    #Regex from:
    #   http://code.izzid.com/2011/08/25/How-to-reverse-complement-a-DNA-sequence-in-perl.html

    my ($before, $middle, $end, $cutindex) = @_;

    #Find the offset
    my $offset = length($middle)-$cutindex;

    #Replace the |
    substr($middle, $offset, 0) = '|';
    my $seq = "$before,$middle,$end";
    $seq =~ tr/acgtrymkbdhvACGTRYMKBDHV/tgcayrkmvhdbTGCAYRKMVHDB/;
    #$seq = reverse($seq);
    
    return $seq;
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
1;
