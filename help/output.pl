#! /usr/bin/perl -w 
#
#   output.pl - Outputs Git Commits to HTML
#   Written by: Joseph Southan
#   Date:       27/4/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      None
#   Requires:   Git::Repository, Git::Repository::Log::Iterator, POSIX
#   Updated:    10/5/13
#
use strict;
use Git::Repository;
use Git::Repository::Log::Iterator;
use Data::Dumper;
use POSIX;

my $git = Git::Repository->new(git_dir => "../.git");
my $iter = Git::Repository::Log::Iterator->new($git, 'HEAD');

my $time = localtime();
open (OUT, ">", "commits.html") or die ("Can't open output file");

print OUT <<__EOF;
<!DOCTYPE HTML>
<html>
<head>
    <meta charset="utf-8">
    <title>12Chrom - Commits</title>
    <link href="../css/style.css" rel="stylesheet" type="text/css">
</head>

<body>
<div class="navbar-wrapper">
    <div class="navbar-inner-wrapper">
        <div class="header">
            <h1>12Chrom - Commits</h1>
        </div>
        <span class="subheader">Chromosome 12 Analysis Tool</span>
        <div class="navbar">
            <div class="item" id="home">
                <a href="index.html">Back</a>
            </div>
        </div>
    </div>
</div>
<div class="wrapper">
<div class="main">
<h2 class="center">Table of Commits</h2>
<p class="center">Last generated on: $time</p>
    <table class="commits">
        <tr class="commits"><td><span class="bold">Author</span></td><td><span class="bold">Description</span></td><td><span class="bold">SHA</span></td><td><span class="bold">EMail</span></td><td><span class="bold">Time</span></td></tr>
__EOF
while (my $log = $iter->next) {
    my $log_time = localtime($log->{author_gmtime});
    my $log_name = $log->{author_name};
    my $log_sub  = $log->{subject};
    my $log_comm = substr($log->{commit}, 0, 6);
    my $log_email = $log->{committer_email};

    print OUT "<tr class=\"commits\"><td>$log_name</td><td><span class=\"bold\">$log_sub</span></td><td>$log_comm(...)</td><td>$log_email</td><td>$log_time</td></tr>\n";
}
print OUT "</div></div></body></html>";
close (OUT) or die("Can't close output file");
