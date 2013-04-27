#! /usr/bin/perl -w
use strict;
package CodonImager;
use Image::Magick;
use CGI;
use Data::Dumper;
use ChromoDB;
use Time::HiRes qw ( time );
use MIME::Base64;

#Initialise CGI
my $cgi = new CGI;
my $path = "./Modules/img/";


sub CreateImage {
	#
	#
	#	Configuration section
	#
	#
		#How big of a box?
			my $boxH = 14;
			my $boxW = 29;
		#Opacity
			my $opacity = 0.7;
		#Colours
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
		#Take the string from the arg
		my $codons = $_[0];
		my %codonUsage = split /[:,]/, $codons;
		#Turn off the buffer
		$! =1;

		#Initialise ImageMagick
		my $image = Image::Magick->new;

		#Columns
			my @ycords = qw ( 66 82 98 114 130 147 163 179 195 211 227 243 259 276 292 308);
			my $startCoord = 58;
			my $br = $startCoord+$boxW;
			#Adjust for bottom right
			my @ycordright;
			for (my $i=0; $i < @ycords; $i++) {
				$ycordright[$i] = $ycords[$i]+$boxH;
			}
			#[Top left Co-ord, bottom right co-ord]
			my %codonPositionsTL = (
				
				#Phy
				"UUU" => ["$startCoord,$ycords[0]", "$br,$ycordright[0]" ],
				"UUC" => ["$startCoord,$ycords[1]", "$br,$ycordright[1]" ],
				#Leu
				
				"UUA" => ["$startCoord,$ycords[2]", "$br,$ycordright[2]" ],
				"UUG" => ["$startCoord,$ycords[3]", "$br,$ycordright[3]" ],
				
				"CUU" => ["$startCoord,$ycords[4]", "$br,$ycordright[4]" ],
				"CUC" => ["$startCoord,$ycords[5]", "$br,$ycordright[5]" ],
				"CUA" => ["$startCoord,$ycords[6]", "$br,$ycordright[6]" ],
				"CUG" => ["$startCoord,$ycords[7]", "$br,$ycordright[7]" ],
				
				#IsoL
				"AUU" => ["$startCoord,$ycords[8]", "$br,$ycordright[8]" ],
				"AUC" => ["$startCoord,$ycords[9]", "$br,$ycordright[9]" ],
				"AUA" => ["$startCoord,$ycords[10]","$br,$ycordright[10]" ],
				
				#MET
				"AUG" => ["$startCoord,$ycords[11]", "$br,$ycordright[11]"],
				
				#VALINE
				"GUU" => ["$startCoord,$ycords[12]", "$br,$ycordright[12]"],
				"GUC" => ["$startCoord,$ycords[13]", "$br,$ycordright[13]"],
				"GUA" => ["$startCoord,$ycords[14]", "$br,$ycordright[14]"],
				"GUG" => ["$startCoord,$ycords[15]", "$br,$ycordright[15]"]
			);


			#Open image
			my $output = $image->Read($path.'codon.gif');
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
				#print "$opacity $r $g $b \n";
				$output = $image->Draw(primitive=>"rectangle",fill=>"rgba($r,$b,$g,$opacity)",points=>"$codonPositionsTL{$key}[0] $codonPositionsTL{$key}[1] ");
					warn "$output" if "$output";
			}


		return $image;
		#$image->Display(); #Debug:
}

sub displayImg {
	my $image = CreateImage($_[0]);
	print $cgi->header(-type =>'image/png');
	$! =1;
	binmode STDOUT;
	$image->Write("png:-");
	exit;
}

sub downloadImg {
	my $image = CreateImage($_[0]);
	print $cgi->header(-type =>'image/png', -attachment => 'codon_imager.png');
	$! =1;
	binmode STDOUT;
	$image->Write("png:-");
	exit;
}
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