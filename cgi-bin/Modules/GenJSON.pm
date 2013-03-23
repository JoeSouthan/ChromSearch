#! /usr/bin/perl -w
package GenJSON;
use strict;
use JSON;
use ChromoDB;
use Exporter;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw ();

sub testJSONSearch {
	my $json = JSON->new;
	my @array = qw( NCS:5 EXON:20 INTRON:40 EXON:40 );
	my @array2 = qw( NCS:30 EXON:10 INTRON:40 EXON:9 );
	my @array3 = qw( NCS:11 EXON:60 INTRON:50 EXON:40 INTRON:40 EXON:514);

	my %data = ( 
		"gene1" => {
				"name" => "Test1",
				"length"=> 123,
				"sequencefeatures" => [@array],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			},
		"gene2" => {
				"name" => "Test2",
				"length"=> 123,
				"sequencefeatures" => [@array2],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			},
		"gene3" => {
				"name" => "Test3",
				"length"=> 123,
				"sequencefeatures" => [@array3],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			},
		"gene4" => {
				"name" => "Test3",
				"length"=> 123,
				"sequencefeatures" => [@array3],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			},		
		"gene5" => {
				"name" => "Test3",
				"length"=> 123,
				"sequencefeatures" => [@array3],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			},		
		"gene6" => {
				"name" => "Test3",
				"length"=> 123,
				"sequencefeatures" => [@array3],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			},
		"gene7" => {
				"name" => "Test3",
				"length"=> 123,
				"sequencefeatures" => [@array3],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			}
	);
	
	#new element
	# $data{'gene4'}{'accession'} = "test4";
	# $data{'gene4'}{'length'} = 123456;
	# $data{'gene4'}{'sequencefeatures'} = [@array];
	# $data{'gene4'}{'somethingelse'} = "Something";
	#Prints "Test2"
	#print $data{'gene2'}{'accession'};
	return $json->pretty->encode(\%data);
}
sub testJSONSingle {
	my $json = JSON->new;
	my @array = qw( test appples cake cats );
	my %data = ( 
		#accession
		"12345" => {
				"name" => "Test",
				"length"=> 123,
				"sequencefeatures" => [@array],
				"aasequence" => "ANONVAVAFIROEIRW",
				"dnasequence" => "ATGCATGC"
			}
	);
	return $json->pretty->encode(\%data);
}
sub doSearch {
	my $json = JSON->new;
	my ($query,$type)= @_;
	my %result = ChromoDB::getSearchResults($query,$type);
	return $json->pretty->encode(\%result);

}
sub doSingle {
	my $json = JSON->new;
	my ($query)= @_;
	my %result = ChromoDB::shwoSingle($query);
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