#! /usr/bin/perl -w
package HelpText;
use strict;
use Exporter;
use Pod::Simple::HTML;
use File::Slurp;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw (helpTextError helpTextSearch);


sub helpTextError {
	my @files = glob ("help/*.pod");
	my %help;
	for (my $i=0; $i<@files; $i++) {
		my $sectionName;
		if ($files[$i] =~ /help\/(\d+)_(\w+_\w+?).pod/ ) {
			$sectionName = "$1-$2";
		} else {
			last;
		}
		my @filearray = read_file($files[$i]);
		$help{$sectionName} = [@filearray];
	}
	
	#Index of help
	print "--Index--\n";
	for my $keys (sort keys %help) {
		print "$keys\n";
	}
	print "--End--\n";
	#Help itself
	for my $keys (sort keys %help) {
		print "$keys\n@{$help{$keys}} ";
	}
	
}
sub helpText {
	print <<__HELP	

__HELP
}
1;