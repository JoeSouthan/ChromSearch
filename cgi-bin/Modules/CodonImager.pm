#! /usr/bin/perl -w
use strict;
package CodonImager;
use Image::Magick;
use Time::HiRes qw ( time );
use MIME::Base64;

sub CreateImage {
#Take the string from the arg
my $codons = $_[0];
my %codonUsage = split /[:,]/, $codons;

#Create Image
my $image = Image::Magick->new;
my $boxH = 14;
my $boxW = 29;
my $directory = "/home/lighttpd/coursework/http/tmp";
my $opacity = 0.7;
# my %colours = (
	# "0.1" => "rgba(151,151,151,$opacity)",
	# "0.2" => "rgba(139,131,120,$opacity)",
	# "0.3" => "rgba(143,0,255,$opacity)",
	# "0.4" => "rgba(111,0,200,$opacity)",
	# "0.5" => "rgba(0,0,255,$opacity)",
	# "0.6" => "rgba(0,225,0,$opacity)",
	# "0.7" => "rgba(225,225,0,$opacity)",
	# "0.8" => "rgba(255,127,0,$opacity)",
	# "0.9" => "rgba(210,105,30,$opacity)",
	# "1.0" => "rgba(255,0,0,$opacity)"
# );

#
# Do not edit
#
my @ycords = qw ( 66 82 98 114 130 147 163 179 195 211 227 243 259 276 292 308);
my %codonPositionsTL = (
	
	#Phy
	"UUU" => "58,$ycords[0]",
	"UUC" => "58,$ycords[1]",
	#Leu
	
	"UUA" => "58,$ycords[2]",
	"UUG" => "58,$ycords[3]",
	
	"CUU" => "58,$ycords[4]",
	"CUC" => "58,$ycords[5]",
	"CUA" => "58,$ycords[6]",
	"CUG" => "58,$ycords[7]",
	
	#IsoL
	"AUU" => "58,$ycords[8]",
	"AUC" => "58,$ycords[9]",
	"AUA" => "58,$ycords[10]",
	
	#MET
	"AUG" => "58,$ycords[11]",
	
	#VALINE
	"GUU" => "58,$ycords[12]",
	"GUC" => "58,$ycords[13]",
	"GUA" => "58,$ycords[14]",
	"GUG" => "58,$ycords[15]",
);

#Bottom Right Coordinate
my @ycordright;
my $br = 58+$boxW;
for (my $i=0; $i < @ycords; $i++) {
	$ycordright[$i] = $ycords[$i]+$boxH;
}
my %codonPositionsBR = (
	
	#Phy
	"UUU" => "$br,$ycordright[0]",
	"UUC" => "$br,$ycordright[1]",
	#Leu
	
	"UUA" => "$br,$ycordright[2]",
	"UUG" => "$br,$ycordright[3]",
	
	"CUU" => "$br,$ycordright[4]",
	"CUC" => "$br,$ycordright[5]",
	"CUA" => "$br,$ycordright[6]",
	"CUG" => "$br,$ycordright[7]",
	
	#IsoL
	"AUU" => "$br,$ycordright[8]",
	"AUC" => "$br,$ycordright[9]",
	"AUA" => "$br,$ycordright[10]",
	
	#MET
	"AUG" => "$br,$ycordright[11]",
	
	#VALINE
	"GUU" => "$br,$ycordright[12]",
	"GUC" => "$br,$ycordright[13]",
	"GUA" => "$br,$ycordright[14]",
	"GUG" => "$br,$ycordright[15]",
);
#my %codonUsage = (
#	#Phy
#	"UUU" => 0.9,
#	"UUC" => 0.2,
#	#Leu
#	"UUA" => 0.5,
#	"UUG" => 0.1,
#	
#	"CUU" => 0.7,
#	"CUC" => 0.5,
#	"CUA" => 0.6,
#	"CUG" => 0.41,
#	
#	#IsoL
#	"AUU" => 0.1,
#	"AUC" => 0.6,
#	"AUA" => 0.9,
#	
	#MET
#	"AUG" => 0.1,
#	
#	#VALINE
#	"GUU" => 0.2,
#	"GUC" => 0.5,
#	"GUA" => 0.4,
#	"GUG" => 0.3,
#);


#Open image
my $output = $image->Read('codon.gif');
	warn "$output" if "$output";

#Draw overlay
#Load each position key=codon 
foreach my $key (keys %codonUsage) {
	#fancy colours
	my $codonFreq = $codonUsage{$key};
	my ($r,$g,$b) = (255, 0, 0);

	$r = $r*$codonFreq;
	$g = $g*$codonFreq;
	$b = $b*$codonFreq;
	
	$output = $image->Draw(primitive=>"rectangle",fill=>"rgba($r,$b,$g,$opacity)",points=>"$codonPositionsTL{$key} $codonPositionsBR{$key} ");
		warn "$output" if "$output";
}

#Output image
#return $output;

my $time = time();
$image->Write("tmp/$time.png");
#sleep 10;
#unlink "tmp/$time.png";
return "tmp/$time.png";

#$image->Display(); #Debug:


}
1;