#! /usr/bin/perl -w
#
#	GenJSON.pm - Generates JSON
#	Written by: Joseph Southan
#	Date: 		18/3/13
#	Email:		joseph@southanuk.co.uk
#	Usage: 		*See functions*
#	Requires:	JSON, ChromoDB, EnzCutter
#	Updated:	3/5/13
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

sub doSearch {
	my $json = JSON->new;
	my ($query,$type)= @_;
	my %result = ChromoDB::GetSearchResults($query,$type,0);
	return $json->pretty->encode(\%result);

}
sub doSingle {
	my $json = JSON->new;
	my ($query)= @_;
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

	return $json->pretty->encode(\%result);

}
sub doBrowse {
	my $json = JSON->new;
	my ($query)= @_;
	my $type = "AccessionNumber";
	my %result = ChromoDB::GetSearchResults($query,$type,1);
	return $json->pretty->encode(\%result);

}
#Gets the restriction enzymes and their cut sites
sub getRes {
	my $json = JSON->new;
	my %result = ChromoDB::GetRES();
	return $json->pretty->encode(\%result);
}
sub CalcRES {
	my $json = JSON->new;
	my ($query, $enz) = @_;
	#Remove %2C's 
	if ($enz =~s/%2C/\,/g) {
		#Need logic for duplicates
	}
	my %result = EnzCutter::doCut($query,$enz);	
	return $json->pretty->encode(\%result);

}
sub help {
	my $json = JSON->new;
	my %result = @_;
	return $json->pretty->encode(\%result);
 
}
sub error {
	my $json = JSON->new;
	my %error = (
		"error" => "$_[0]"
	);
	return $json->pretty->encode(\%error);
}
1;