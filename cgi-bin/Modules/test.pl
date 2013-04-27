#! /usr/bin/perl -w
#
# Script Name
# Created by: Joseph Southan
# Date:
# Description:
#
use strict;
use Data::Dumper;

use ChromoDB;

my $query = "AB002805";
my %result = ChromoDB::GetSearchResults($query,"AccessionNumber",2);
print Dumper %result;
print ref($result{$query}{"CodonUsage"}[0]);