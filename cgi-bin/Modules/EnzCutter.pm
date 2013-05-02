#! /usr/bin/perl -w
#
#	EnzCutter.pm - Cleaves a sequence
#	Written by: Joseph Southan
#	Date: 		15/2/13
#	Email:		joseph@southanuk.co.uk
#	Usage: 		*See Functions*
#	Requires:	ChromoDB
#	Updated:	3/5/13
#
package EnzCutter;
use strict;
use ChromoDB;
use Exporter;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw ();



sub doCut {	
	my (%result,$sequence);

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
	} elsif ($query =~/^>/) {
		#It's a FASTA sequence
		$sequence = $query;
	} elsif ($query =~/\d+?/g) {
		$result{"result"} = {"error" => "Numbers detected"};
		return %result;
	} else {
		#Its a pasted sequence
		$sequence = $query;
	}

	#Process the sequence
	foreach my $enzymes (@enz) {
		#Get the cutsite
		my ($cutsite,%cutresult,$cutindex);
		if ($enzymes=~/[|]/) {
			#For custom cut sites
			$cutsite = $enzymes;
		} else {
			$cutsite = $currentRES{$enzymes};
		}
		#Remove the |
		my $cutsitemodified = $cutsite;
		#Find it's index
		$cutindex = index($cutsite, "|");
		$cutsitemodified =~ s/[|]//;

		my $count = 0;
		while ($sequence =~ /(.{1,5}?)($cutsitemodified)(.{5}?)/g){
			my $firstchar = $-[0]+2;
			my $secondchar = $+[0]-1;
			my %info;


			my $forwardseq = "$1,$cutsite,$3";
			my $reverseseq = reverseSeq($1,$2,$3,$cutindex);

			$info{"cut"} = $cutsite;
			$info{"location"} = "$firstchar,$secondchar";
			$info{"sequence-forward"} = $forwardseq;
			$info{"sequence-reverse"} = $reverseseq;

			$cutresult{"cut".$count} = \%info;
			$count++;
		}

		unless (%cutresult) {
			my %error = ("error" => "No Cuts");
			$result{"result"}{$enzymes} = \%error;
		} else {
			$result{"result"}{$enzymes} = \%cutresult;
		}

	}

	#print Dumper %result;
	return %result;
}
sub reverseSeq {
	#http://code.izzid.com/2011/08/25/How-to-reverse-complement-a-DNA-sequence-in-perl.html
	my $cutindex = pop @_;
	my ($before, $middle, $end) = @_;
	#Find the offset
	my $offset = length($middle)-$cutindex;
	#Replace the |
	substr($middle, $offset, 0) = '|';
	my $seq = "$before,$middle,$end";
	$seq =~ tr/acgtrymkbdhvACGTRYMKBDHV/tgcayrkmvhdbTGCAYRKMVHDB/;
	#$seq = reverse($seq);
	
	return $seq;
}
1;