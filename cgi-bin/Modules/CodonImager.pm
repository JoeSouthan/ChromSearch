#! /usr/bin/perl -w
#
#   CodonImager.pm - Creates images dynamically
#   Written by: Joseph Southan
#   Date:       5/2/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      *See Functions*
#   Requires:   Image::Magick, CGI, CGI::Carp, ChromoDB
#   Updated:    3/5/13
#
package CodonImager;
use strict;
use Image::Magick;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Data::Dumper;
use ChromoDB;

#Initialise CGI
my $cgi = new CGI;
my $path = "./Modules/img/";
###############################################################################################################################
#   Function:       displayImg                                                                                                #
#   Description:    Prints a HTML header and image Data                                                                       #
#   Usage:          displayImg([AccessionNumber])                                                                             #
#   Returns:        PNG image file                                                                                            #
########################################################################################################################################################
sub displayImg {
    my $image = CreateImage($_[0]);
    print $cgi->header(-type =>'image/png');
    $! =1;
    binmode STDOUT;
    $image->Write("png:-");
    exit;
}
###############################################################################################################################
#   Function:       downloadImg                                                                                               #
#   Description:    Prints a HTML header and image Data, for download                                                         #
#   Usage:          downloadImg([AccessionNumber])                                                                            #
#   Returns:        PNG image file                                                                                            #
########################################################################################################################################################
sub downloadImg {
    my $image = CreateImage($_[0]);
    print $cgi->header(-type =>'image/png', -attachment => 'codon_imager.png');
    $! =1;
    binmode STDOUT;
    $image->Write("png:-");
    exit;
}
###############################################################################################################################
#   Function:       CreateImage                                                                                               #
#   Description:    Creates a codon usage heat map                                                                            #
#   Usage:          CreateImage([AccessionNumber])                                                                            #
#   Returns:        PNG image Data                                                                                            #
########################################################################################################################################################
sub CreateImage {
        my $boxH = 15;
        my $boxW = 31;
    #Opacity
        my $opacity = 0.7;

        #Take the query 
        my $query = $_[0];
        
        #Get the result
        my %result = ChromoDB::GetSearchResults($query,"AccessionNumber",2);
        my %codonUsage;

        #Sort out the codon usages
        my @usage_AminoAcids = keys ($result{$query}{"CodonUsage"});
        foreach my $key (@usage_AminoAcids){
            my @codon_usage = keys ($result{$query}{"CodonUsage"}{$key});
            foreach my $subkey (@codon_usage){
                $codonUsage{$subkey} = $result{$query}{"CodonUsage"}{$key}{$subkey}->[0];
            }
        }
        #Turn off the buffer
        $! =1;

        #Initialise ImageMagick
        my $image = Image::Magick->new;

        #Columns
            my @ycords = qw ( 66 82 98 114 130 146 163 179 195 211 227 243 259 276 292 308);
            my @startCords = qw (57 154 250 346);
            my @br;
            my @ycordright;
            for (my $i=0; $i < @startCords; $i++) {
                $br[$i] = $startCords[$i]+$boxW;
            }
            #Adjust for bottom right
            for (my $i=0; $i < @ycords; $i++) {
                $ycordright[$i] = $ycords[$i]+$boxH;
            }
            #[Top left Co-ord, bottom right co-ord]
            my %codonPositionsTL = (
                
                #Phy
                "UUU" => ["$startCords[0],$ycords[0]", "$br[0],$ycordright[0]" ],
                "UUC" => ["$startCords[0],$ycords[1]", "$br[0],$ycordright[1]" ],
                #Leu
                
                "UUA" => ["$startCords[0],$ycords[2]", "$br[0],$ycordright[2]" ],
                "UUG" => ["$startCords[0],$ycords[3]", "$br[0],$ycordright[3]" ],
                
                "CUU" => ["$startCords[0],$ycords[4]", "$br[0],$ycordright[4]" ],
                "CUC" => ["$startCords[0],$ycords[5]", "$br[0],$ycordright[5]" ],
                "CUA" => ["$startCords[0],$ycords[6]", "$br[0],$ycordright[6]" ],
                "CUG" => ["$startCords[0],$ycords[7]", "$br[0],$ycordright[7]" ],
                
                #IsoL
                "AUU" => ["$startCords[0],$ycords[8]", "$br[0],$ycordright[8]" ],
                "AUC" => ["$startCords[0],$ycords[9]", "$br[0],$ycordright[9]" ],
                "AUA" => ["$startCords[0],$ycords[10]","$br[0],$ycordright[10]" ],
                
                #MET
                "AUG" => ["$startCords[0],$ycords[11]", "$br[0],$ycordright[11]"],
                
                #VALINE
                "GUU" => ["$startCords[0],$ycords[12]", "$br[0],$ycordright[12]"],
                "GUC" => ["$startCords[0],$ycords[13]", "$br[0],$ycordright[13]"],
                "GUA" => ["$startCords[0],$ycords[14]", "$br[0],$ycordright[14]"],
                "GUG" => ["$startCords[0],$ycords[15]", "$br[0],$ycordright[15]"],
                
                #Ser
                "UCU" => ["$startCords[1],$ycords[0]", "$br[1],$ycordright[0]"],
                "UCC" => ["$startCords[1],$ycords[1]", "$br[1],$ycordright[1]"],
                "UCA" => ["$startCords[1],$ycords[2]", "$br[1],$ycordright[2]"],
                "UCG" => ["$startCords[1],$ycords[3]", "$br[1],$ycordright[3]"],

                #Pro
                "CCU" => ["$startCords[1],$ycords[4]", "$br[1],$ycordright[4]"],
                "CCC" => ["$startCords[1],$ycords[5]", "$br[1],$ycordright[5]"],
                "CCA" => ["$startCords[1],$ycords[6]", "$br[1],$ycordright[6]"],
                "CCG" => ["$startCords[1],$ycords[7]", "$br[1],$ycordright[7]"],

                #Thr
                "ACU" => ["$startCords[1],$ycords[8]", "$br[1],$ycordright[8]"],
                "ACC" => ["$startCords[1],$ycords[9]", "$br[1],$ycordright[9]"],
                "ACA" => ["$startCords[1],$ycords[10]", "$br[1],$ycordright[10]"],
                "ACG" => ["$startCords[1],$ycords[11]", "$br[1],$ycordright[11]"],

                #Ala
                "GCU" => ["$startCords[1],$ycords[12]", "$br[1],$ycordright[12]"],
                "GCC" => ["$startCords[1],$ycords[13]", "$br[1],$ycordright[13]"],
                "GCA" => ["$startCords[1],$ycords[14]", "$br[1],$ycordright[14]"],
                "GCG" => ["$startCords[1],$ycords[15]", "$br[1],$ycordright[15]"],

                #Tyr
                "UAU" => ["$startCords[2],$ycords[0]", "$br[2],$ycordright[0]"],
                "UAC" => ["$startCords[2],$ycords[1]", "$br[2],$ycordright[1]"],

                #Stop
                "UAA" => ["$startCords[2],$ycords[2]", "$br[2],$ycordright[2]"],
                "UAG" => ["$startCords[2],$ycords[3]", "$br[2],$ycordright[3]"],

                #His
                "CAU" => ["$startCords[2],$ycords[4]", "$br[2],$ycordright[4]"],
                "CAC" => ["$startCords[2],$ycords[5]", "$br[2],$ycordright[5]"],

                #Gln
                "CAA" => ["$startCords[2],$ycords[6]", "$br[2],$ycordright[6]"],
                "CAG" => ["$startCords[2],$ycords[7]", "$br[2],$ycordright[7]"],

                #Asn
                "AAU" => ["$startCords[2],$ycords[8]", "$br[2],$ycordright[8]"],
                "AAC" => ["$startCords[2],$ycords[9]", "$br[2],$ycordright[9]"],

                #Lys
                "AAA" => ["$startCords[2],$ycords[10]", "$br[2],$ycordright[10]"],
                "AAG" => ["$startCords[2],$ycords[11]", "$br[2],$ycordright[11]"],

                #Asp
                "GAU" => ["$startCords[2],$ycords[12]", "$br[2],$ycordright[12]"],
                "GAC" => ["$startCords[2],$ycords[13]", "$br[2],$ycordright[13]"],

                #Glu
                "GAA" => ["$startCords[2],$ycords[14]", "$br[2],$ycordright[14]"],
                "GAG" => ["$startCords[2],$ycords[15]", "$br[2],$ycordright[15]"],

                #Cys
                "UGU" => ["$startCords[3],$ycords[0]", "$br[3],$ycordright[0]"],
                "UGC" => ["$startCords[3],$ycords[1]", "$br[3],$ycordright[1]"],

                #Stop
                "UGA" => ["$startCords[3],$ycords[2]", "$br[3],$ycordright[2]"],

                #Trp
                "UGG" => ["$startCords[3],$ycords[3]", "$br[3],$ycordright[3]"],

                #Arg
                "CGU" => ["$startCords[3],$ycords[4]", "$br[3],$ycordright[4]"],
                "CGC" => ["$startCords[3],$ycords[5]", "$br[3],$ycordright[5]"],
                "CGA" => ["$startCords[3],$ycords[6]", "$br[3],$ycordright[6]"],
                "CGG" => ["$startCords[3],$ycords[7]", "$br[3],$ycordright[7]"],

                #Ser
                "AGU" => ["$startCords[3],$ycords[8]", "$br[3],$ycordright[8]"],
                "AGC" => ["$startCords[3],$ycords[9]", "$br[3],$ycordright[9]"],

                #Arg
                "AGA" => ["$startCords[3],$ycords[10]", "$br[3],$ycordright[10]"],
                "AGG" => ["$startCords[3],$ycords[11]", "$br[3],$ycordright[11]"],

                #Gly
                "GGU" => ["$startCords[3],$ycords[12]", "$br[3],$ycordright[12]"],
                "GGC" => ["$startCords[3],$ycords[13]", "$br[3],$ycordright[13]"],
                "GGA" => ["$startCords[3],$ycords[14]", "$br[3],$ycordright[14]"],
                "GGG" => ["$startCords[3],$ycords[15]", "$br[3],$ycordright[15]"]


            );

            #Open image
            my $output = $image->Read($path.'codon.gif');
            warn "$output" if "$output";

            #Draw overlay
            #Load each position key=codon 
            foreach my $key (keys %codonUsage) {
                if (defined($codonPositionsTL{$key})){
                    #fancy colours
                    my $codonFreq = $codonUsage{$key};
                    my $r = 255;
                    my $op = $opacity*$codonFreq;
                    unless ($op == 0) {
                    $output = $image->Draw(primitive=>"rectangle",fill=>"rgba($r,0,0,$op)",points=>"$codonPositionsTL{$key}[0] $codonPositionsTL{$key}[1] ");
                    warn "$output" if "$output";
                    }
                }
            }

        return $image;
        #$image->Display(); #Debug:
}
###############################################################################################################################
#   Function:       error                                                                                                     #
#   Description:    Prints a HTML header and image Data in case of errors                                                     #
#   Usage:          error()                                                                                                   #
#   Returns:        PNG image file                                                                                            #
########################################################################################################################################################
sub error {
    print $cgi->header(-type =>'image/png');
    $! =1;
    binmode STDOUT;
    my $image = Image::Magick->new;
    my $output = $image->Read($path.'error.png');
    warn "$output" if "$output";
    $image->Write("png:-");
}
1;
