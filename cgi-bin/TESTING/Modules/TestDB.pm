package TestDB;

use DBI;
use strict;

sub doconnect {
	my $user = "c2";
	my $password = "coursework123";
	my $datasource = "dbi:mysql:database=biocomp2;host=localhost";
	my $dbh = DBI->connect($datasource, $user, $password);
	
	if ($dbh) {
		return "Connection complete";
		} else {
		return "Connection failed";
	}
	
}
sub ping {
	return "Hello";
	}
	
1;