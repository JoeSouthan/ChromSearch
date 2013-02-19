#! /usr/bin/perl -w
package GenJS;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw (genChartJS genResultJS);

#=============================
#	JS Output
#		Ouputs Google Charts Bar Chart javascript
#		Takes:
#			[0] = Result hash reference
#=============================
sub genChartJS {
	my $count2 = 0;
	my %resultHash = %{$_[0]};
	print <<__JS1;
	<script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
    function drawChart() {
       var options = {
          isStacked: true,
          hAxis : {},
          legend: {},
          chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'},
          width: 650,
          height: 50
        };
__JS1
	for my $genes (sort keys %resultHash){
		#Start a counter - Maintains order
		my $count=0;
		#Get the array from the hash
		my @sequence = @{$resultHash{$genes}};
		
		#get the sequence lengths
		my %sequenceLength;
		foreach my $seq (@sequence) {
			if ($seq =~/^NCS:(.*)/) {
				my $hashKey = $count."NCS";
				$sequenceLength{ $hashKey } = length ($1);
				$count++;
			} elsif ($seq =~/^CODON:(.*)/){
				my $hashKey = $count."CODON";
				$sequenceLength{ $hashKey } = length ($1);
				$count++;
			} elsif ($seq =~/^INTRON:(.*)/){
				my $hashKey = $count."INTRON";
				$sequenceLength{ $hashKey } = length ($1);
				$count++;
			}
		}
		#Total Length
		# my $totalLength;
		# for my $counts (values %sequenceLength) {
			# $totalLength += $counts;
		# }
		print "\t\tvar data$count2 = google.visualization.arrayToDataTable([\n";
		#Build the table Headers
		#eg ['Gene', 'NCR', 'Intron', 'Exon'],
		my $header = "['Gene', "; 
		#Now do the data
		#['$genes',  1000,      400, 500]
		my $data = "['$genes' ,";
		for my $types (sort keys %sequenceLength){
			$header .= " '$types' ,";
			$data .= " $sequenceLength{$types} ,";
		}
		$header .= " 'End' ],";
		$data .= " 0] \t\t\n\]\)\;";
		print "\t\t$header\n\t\t$data\n";

        #]);
		
		print <<__JS2;
		var chart$count2 = new google.visualization.BarChart(document.getElementById('chart_div$count2'));
        chart$count2.draw(data$count2, options);
__JS2
		$count2++;
	}
	print <<__JS3;
		}
		google.setOnLoadCallback(drawChart);
		google.load("visualization", "1", {packages:["corechart"]});

	</script>
__JS3
}
#=============================
#	JS Output
#		Ouputs Ajax loader for enzymes
#		Takes:
#			[0] = GeneID String
#=============================
sub genResultJS {
print <<__JS;
	<script language="javascript" type="text/javascript">
\$(document).ready(function(){ 
	\$.ajaxSetup({
		url: 'load_enz.pl',
		data: {'gene': '$_[0]'},
        beforeSend: function(xhr, status) {
            \$("#spinner").fadeIn("fast");
        },
        complete: function(xhr, status) {
            \$("#spinner").fadeOut("fast");
			\$("#cutter").slideDown("fast");
			\$("cutter-text").fadeOut("fast");
			\$("#cutter-text").html("Please Choose what restriction enzymes to cut with:");
			\$("cutter-text").fadeIn("fast");
        }
    });
	\$("#show4").click(function() {
	  \$("#cutter").load("load_enz.pl");
	});	
});
</script>
__JS
}
1;