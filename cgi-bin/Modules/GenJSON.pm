#! /usr/bin/perl -w
package GenJSON;
use strict;
use JSON;
use ChromoDB;
use Exporter;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw ();

sub doSearch {
	my $json = JSON->new;
	my ($query,$type)= @_;
	my %result = ChromoDB::GetSearchResults($query,$type);
	return $json->pretty->encode(\%result);

}
sub doSingle {
	my $json = JSON->new;
	my ($query,$type)= @_;
	$type = "GeneID";
	my %result = ChromoDB::getSearchResults($query,$type);
	return $json->pretty->encode(\%result);

}
#Gets the restriction enzymes and their cut sites
sub getRes {
	my $json = JSON->new;
	my %result = ChromoDB::GetRES();
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