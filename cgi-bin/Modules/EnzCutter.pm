#! /usr/bin/perl -w
#
#
#	EnzCutter.pm - Module to enzymatically cleave DNA Sequences
#
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

	if (7 > length($query)){
		#Its a pasted sequence
		$sequence = $query;
	} else {
		#Its a known gene
		#Get it's sequence
		
		my %search = ChromoDB::GetSearchResults($query,"AccessionNumber", 2);
		$sequence = $search{$query}{"DNASeq"};
	}

	#Process the sequence
	foreach my $enzymes (@enz) {
		#Get the cutsite
		my ($cutsite,%cutresult);
		if ($enzymes=~/[|]/) {
			#For custom cut sites
			$cutsite = $enzymes;
		} else {
			$cutsite = $currentRES{$enzymes};
		}
		#Remove the |
		my $cutsitemodified = $cutsite;
		$cutsitemodified =~ s/[|]//;

		my $count = 0;
		while ($sequence =~ /(.?)($cutsitemodified)(.?)/g){
			my $firstchar = $-[0]+2;
			my $secondchar = $+[0]-1;
			my %info;

			my $forwardseq = "$1$2$3";
			my $reverseseq = reverseSeq($forwardseq);

			$info{"cut"} = $cutsite;
			$info{"location"} = "$firstchar,$secondchar";
			$info{"sequence-forward"} = $forwardseq;
			$info{"sequence-reverse"} = $reverseseq;

			$cutresult{"cut".$count} = \%info;
			$count++;
		}
		unless (%cutresult) {
			$result{"result"}{$enzymes} = "No Cuts";
		} else {
			$result{"result"}{$enzymes} = \%cutresult;
		}

	}

	#print Dumper %result;
	return %result;
}
sub reverseSeq {
	#http://code.izzid.com/2011/08/25/How-to-reverse-complement-a-DNA-sequence-in-perl.html
	my $seq = $_[0];
	$seq =~ tr/acgtrymkbdhvACGTRYMKBDHV/tgcayrkmvhdbTGCAYRKMVHDB/;
	#$seq = reverse($seq);
	return $seq;
}
1;