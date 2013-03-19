#! /usr/bin/perl -w
package GenJSON;
use strict;
use JSON;
#use ChromoDB;
use Exporter;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw ();

sub testJSONSearch {
	my $json = JSON->new;
	my @array = qw( test appples cake cats );
	my %data = ( 
		"gene1" => {
				"accession" => "Test",
				"length"=> 123,
				"sequencefeatures" => [@array]
			},
		"gene2" => {
				"accession" => "Test2",
				"length"=> 1234,
				"sequencefeatures" => [@array]
			},
		"gene3" => {
				"accession" => "Test3",
				"length"=> 12345,
				"sequencefeatures" => [@array]
			}
	);
	
	#new element
	$data{'gene4'}{'accession'} = "test4";
	$data{'gene4'}{'length'} = 123456;
	$data{'gene4'}{'sequencefeatures'} = [@array];
	$data{'gene4'}{'somethingelse'} = "Something";
	#Prints "Test2"
	#print $data{'gene2'}{'accession'};
	return $json->encode(\%data);
}
sub testJSONSingle {
	my $json = JSON->new;
	my @array = qw( test appples cake cats );
	my %data = ( 
		"gene1" => {
				"accession" => "Test",
				"length"=> 123,
				"sequencefeatures" => [@array]
			}
	);
	return $json->encode(\%data);
}
sub doSearch {
	my $json = JSON->new;
	my ($query,$type)= @_;
	my %result = ChromoDB::getSearchResults($query,$type);
	return $json->encode(\%result);

}
sub doSingle {
	my $json = JSON->new;
	my ($query)= @_;
	my %result = ChromoDB::shwoSingle($query);
	return $json->encode(\%result);

}
sub error {
	my $json = JSON->new;
	my %error = (
		"error" => "$_[0]"
	);
	return $json->encode(\%error);
}
1;