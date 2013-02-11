#! /usr/bin/perl -w
use strict;
use CGI;
my $cgi = new CGI;
my @files = glob ("tmp/*.png");
my $count = scalar(@files);

unless (@files) {
	$count = 0;
	$files[0] = "None";
}
foreach my $file (@files) {
	unlink $file;
}

print $cgi->header();
print <<__HTML;
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<title>Files Removed: $count</title>
</head>

<body>
<h1>Files removed: $count</h1>
__HTML
foreach my $files2 (@files) {
	print "<p>$files2</p>\n";
}
print <<__HTML2;

</body>
</html>
__HTML2
