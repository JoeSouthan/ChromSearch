#! /usr/bin/perl -w
use strict;
use SOAP::Lite;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Time::HiRes qw ( time );
use Data::Dumper;
use lib 'Modules';
use WebHTML;
my $timestart = time();
my $cgi = new CGI;
my @params= $cgi->param();
my $soap = SOAP::Lite->uri('ChromoDB')->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');


#Do search, Take post
#Declaring variables for search
my ($query, $type, @queryFault, $fault, $perpage, $pageNumber);


#Take the Params from the POST
foreach my $params (@params) {
	if ($params eq "query") {
		$query = $cgi->param($params);
	} elsif ($params eq "searchType") {
		$type = $cgi->param($params);
	} elsif ($params eq "perpage") {
		$perpage = $cgi->param($params);
	} elsif ($params eq "page") {
		$pageNumber = $cgi->param($params);
	}
}

#Set default page limit just incase
unless (defined($perpage)) {
	$pageNumber = 0;
	$perpage = 10;
}



#Do Results				
#Subroutine to call from the package
#Debug
#$query = "2780780";
#$type = "GeneID";
my $returnSearch = $soap->getSearchResults($query,$type)->result;

#Parse the result to array
my %results;
my @resultArray = split ( ',', $returnSearch);
my @sequences;

#Debug
@sequences = qw ( NCS:ATGCCCCCATATATATATACCCCATATA CODON:ATATATATATATATATATTAT INTRON:CCCCAAATTTATTTATTAT CODON:ATATATATATATATATATTAT INTRON:CCCCAAATTTATTTATTAT);
#	Limitation! 
#	All gene names must be unique
#@resultArray = qw (01 02 03 04 05 06 07 08 09 10 11);

#Build the result hash
#Change @sequences-> @sequenceFetch once showcodingseq is implimented
for (my $i=0; $i<@resultArray; $i++){
	#get the sequence
	#my @sequenceFetch = $soap->showCodingSequence($resultArray[$i])->result;
	#Debug
	$results{$resultArray[$i]} = [@sequences];
}
#Reference
my $resultRef = \%results;

#Pagination
	my $resultCount = scalar keys %results;
	my $pagecount = int(($resultCount/$perpage)+1);
	my $beforeCount = $pageNumber * $perpage;
	my @before;
	my @after;
	my %result_copy;
	#Look through the hash, find what to delete
	#Count before
	my $count = 0;
	for my $keys (sort keys %results) {
		if ($count >= $beforeCount) {
			last;
		} else {
			$before[$count] = $keys;
			$count++;
		}
	}
	for my $delete (@before) {
			delete $results{$delete};
	}
	#save the x amount needed
	my $afterCounter = 0;
	for my $result (sort keys %results){
		if ($afterCounter >= $perpage){
			last;
		} else {
		$after[$afterCounter] = $result;
		$afterCounter++;
		}
	}
		
	#rebuild results
	foreach my $r (@after) {
		$result_copy{$r} = $results{$r};
	}
	#Set the new result hash
	%results = %result_copy;

#Time to check
#Did they enter a query or type?
unless (defined ($query)) {
	push (@queryFault, "No Query entered");
}
unless (defined($type)) {
	push (@queryFault,"No Type selected");
	
}

#Get the errors for the search back
unless (@queryFault){
	if ($returnSearch =~ /^ERROR:(.*)/) {
		$fault = $1;
	}
}


#Stop that clock
my $timestop = time();
my $gentime = $timestop - $timestart;


#Do HTML output
my $faultRef;
if (@queryFault){
	$faultRef = \@queryFault;
	htmlError($cgi,$gentime,$faultRef);
} elsif ($fault) {
	htmlError($cgi,$gentime, $fault);
} else {
	htmlOut ($resultRef, $cgi, $query, $gentime,$pagecount,$pageNumber,$resultCount,$type,$perpage);
}		