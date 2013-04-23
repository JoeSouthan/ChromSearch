#! /usr/bin/perl -w
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
	my $type = "GeneID";
	my %result = ChromoDB::GetSearchResults($query,$type,2);
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