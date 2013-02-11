#! /usr/bin/perl -w
use strict;
use Image::Magick;

my $image = Image::Magick->new;
my $boxH = 14;
my $boxW = 29;

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

#Bottom Right Co-Ordinate
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
my %codonUsage = (
	#Phy
	"UUU" => 0.9,
	"UUC" => 0.2,
	#Leu
	"UUA" => 0.5,
	"UUG" => 0.1,
	
	"CUU" => 0.7,
	"CUC" => 0.5,
	"CUA" => 0.6,
	"CUG" => 0.41,
	
	#IsoL
	"AUU" => 0.1,
	"AUC" => 0.6,
	"AUA" => 0.9,
	
	#MET
	"AUG" => 0.1,
	
	#VALINE
	"GUU" => 0.2,
	"GUC" => 0.5,
	"GUA" => 0.4,
	"GUG" => 0.3,
);


#Open image
my $output;

$output = $image->Read('codon.gif');
warn "$output" if "$output";
#Draw overlay
my $points;
#Load each position key=codon 
foreach my $key (keys %codonPositionsTL) {
	#fancy colours
	my $codonFreq = $codonUsage{$key};
	my ($r,$g,$b) = (255, 0, 0);

	$r = $r*$codonFreq;
	$g = $g*$codonFreq;
	$b = $b*$codonFreq;
	
	$output = $image->Draw(primitive=>"rectangle",fill=>"rgba($r,$g,$b,0.7)",points=>"$codonPositionsTL{$key} $codonPositionsBR{$key} ");
	warn "$output" if "$output";
}

#Output image
print $image->Write('test.png');
#$image->Display(); #Debug:


