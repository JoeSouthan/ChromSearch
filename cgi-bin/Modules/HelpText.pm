#! /usr/bin/perl -w
package HelpText;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw (helpTextError helpTextSearch);

sub helpTextError {
	print <<__ERROR1;
		<h2>Error!</h2>
		<p>Please try again</p>
__ERROR1
}
sub helpText {
	print <<__HELP	

__HELP
}
1;