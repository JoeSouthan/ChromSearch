#! /usr/bin/perl -w
#
#   WebHTML.pm - HTML for fallback mode
#   Written by: Joseph Southan
#   Date:       19/2/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      *see functions*
#   Requires:   EnzCutter, ChromoDB
#   Updated:    10/5/13
#
package WebHTML;
use strict;
use Exporter;
use EnzCutter;
use ChromoDB;
use Data::Dumper;
our @ISA = qw(Exporter);
our @EXPORT = qw (outputSearchHTML outputSingleHTML outputEnzCutter);


###############################################################################################################################
#   Function:       outputSearchHTML                                                                                          #
#   Description:    Outputs the search HTML                                                                                   #
#   Usage:          outputSearchHTML([result hash ref],[CGI object],[search query], [search/browse/error])                    #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub outputSearchHTML {
    my ($resultRef, $cgi, $query, $mode) = @_;
    my %result = %{$resultRef};
    my $count = keys(%result);
    #Output Header
    header($count, $cgi);

    #Output results
    foreach my $key (keys (%result)){
        if ($key eq "error") {
            my $error = $result{"error"};
            error($resultRef, $error);
            last;
        } else {
            result($resultRef, $key);
        }
    }

    #Output Footer
    footer();
}
###############################################################################################################################
#   Function:       outputSingleHTML                                                                                          #
#   Description:    Outputs the single page HTML                                                                              #
#   Usage:          outputSingleHTML([result hash ref],[CGI object],[Accession])                                              #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub outputSingleHTML {
    my ($resultRef, $cgi, $gene) = @_;
    my %result = %{$resultRef};
    my $enz = "EcoRI,BsuMI,BamHI";



    header (0 , $cgi);
    if ($result{"error"}){
        my $error = $result{"error"};
        error($resultRef, $error);
    } else {
        #Make some FASTA sequences
        my $DNAsequence = $result{$gene}{"DNASeq"};
        my $AAsequence = $result{$gene}{"AASeq"};

        #Break it into 70 character Chunks
        my @DNAmod = $DNAsequence =~ /(.{1,70})/g;
        my @AAmod = $AAsequence =~ /(.{1,70})/g;

        #Send it back
        my $geneName = $result{$gene}{"GeneName"};
        my $pID = $result{$gene}{"ProteinId"};
        my $name = $result{$gene}{"ProteinName"};
        unshift (@DNAmod, ">gi|$geneName|gb|$pID|$name");
        unshift (@AAmod, ">gi|$geneName|gb|$pID|$name");
            
        my @featsWithSeqs; 
        my @seq_feats = @{$result{$gene}{"SeqFeat"}};
        if (@seq_feats){
            foreach my $feats (@seq_feats) {
                if ($feats =~ /(\w+)\;(\d*)\:(\d*)/) {
                    my $ext_seq = substr($DNAsequence, $2, $3-$2);
                    push (@featsWithSeqs, "$1|$ext_seq");
                }
            }
        }
        #Do an EnzCutter Cut
        my %EnzCutter_Result = EnzCutter::doCut($gene,$enz);
        my $EnzCutter_Result_ref = \%EnzCutter_Result;

    #Output HTML
    print <<__HTML;
    <div class="searchform"> 
                    <h2 class="center">Single result for: $gene </h2> 
                    <div class="singleresult"> 
                    <div class="single-left"> 
                            <ul> 
                                <li>Length: <span class="bold">$result{$gene}{"GeneLength"}</span></li> 
                                <li>Gene ID: <a href="http://www.ncbi.nlm.nih.gov/nuccore/$result{$gene}{"GeneName"}" target="_blank" title="NCBI">$result{$gene}{"GeneName"}</a></li> 
                                <li>Genbank Accession: <a href="http://www.ncbi.nlm.nih.gov/nuccore/$gene" target="_blank" title="NCBI">$gene</a></li> 
                            </ul> 
                            </div> 
                            <div class="single-left"> 
                            <ul> 
                                <li>Protein ID: <a href="http://www.uniprot.org/uniprot/$result{$gene}{"ProteinId"}\&sort=score" target="_blank" title="UniProt">$result{$gene}{"ProteinId"}</a></li> 
                                <li>Chromosomal Location: <span class="bold">$result{$gene}{"ChromosomeLocation"}</span></li> 
                            </ul> 
                            </div>
                        <div class="single-wide"> 
                            <h2>Protein Product</h2>
                            <p>$name</p>
                            <h2>Sequence Characteristics</h2> 
                            <h3>Sequence Features</h3> 
                            <div class="seq-feats" id="seq-feats-span" style="overflow:auto; height:auto;">
__HTML
                            if (@featsWithSeqs > 1) {
                                foreach my $seqs_f (@featsWithSeqs) {
                                    if ($seqs_f =~ /(.*)\|(.*)/){
                                        print "<span class=\"seq-".$1."\">$2</span>";
                                    }
                                }
                            } else {
                                print "<p class=\"red-b\">No sequence features.</p>";
                            }
                            print <<__HTML0;
                            </div>
                            <p><span class="seq-INTRON">Intron</span>, <span class="seq-EXON">Exon</span>, <span class="seq-NCS">Non Coding Sequence</span></p>
                            <h3>Codon Usage</h3> 
                            <div id="codon_img" class="center"> 
                                <a href="../cgi-bin/codon_img.pl?download=true&gene=$gene" alt="Codon Usage" target="_blank"><img src="../cgi-bin/codon_img.pl?show=true&gene=$gene" alt="Codon Usage" width="500" height="324" /></a> 
                            </div> 
                            <h2>Common Restriction Sites</h2> 
                            <div id="EnzCutter_Results_single" style="display:block;">
__HTML0
                            EnzCutter_Output($EnzCutter_Result_ref);
                            print <<__HTML1;
                            </div> 
                            <h2>EnzCutter</h2> 
                            <div><a href="../cgi-bin/enz_cutter.pl?gene=$gene" target="_blank">Would you like to cut your own?</a></div> 
                        </div> 
                        <div class="clearfix"></div> 
                        <div class="single-wide"> 
                            <h2>Sequences</h2> 
                            <div class="bold" id="show1">DNA Sequence</div> 
                            <div id="SequenceDNA" style="display:block;"> 
__HTML1
                            #Output FASTA DNA
                            foreach my $seq (@DNAmod){
                                print "<p class=\"sequence\">$seq</p>\n";
                            }

                            print <<__HTML2;
                            </div> 
                            <br /> 
                            <div class="bold" id="show2">Translated Amino Acid Sequence</div> 
                            <div id="SequenceAA" style="display:block;"> 
__HTML2
                            #Output AA DNA
                            foreach my $seq (@AAmod){
                                print "<p class=\"sequence\">$seq</p>\n";
                            }
                            print <<__HTML3;
                            </div> 
                            <br /> 
                            <div class="bold" id="show3">Codon usage</div> 
                            <div id="codonusage" style="display:block;"> 
__HTML3
                            #Output Codon Usage
                            if (defined($result{$gene}{"CodonUsage"}{"error"})){
                                print "<p>No Codons</p>";
                            } else {
                                foreach my $codons (keys ($result{$gene}{"CodonUsage"})){
                                    print "<div id=\"aaname\" class=\"bold\">$codons</div>\n";
                                    foreach my $triplets (keys ($result{$gene}{"CodonUsage"}{$codons})){
                                        my @tripletArray = @{$result{$gene}{"CodonUsage"}{$codons}{$triplets}};
                                        print "<pre><span class=\"bold\">$tripletArray[0] </span><span>$tripletArray[1]</span></pre>\n";
                                    }
                                }
                            }
                            print <<__HTML4;
                            </div> 
                        </div> 
                    </div> 
                </div>
__HTML4
    }
    footer();

}
###############################################################################################################################
#   Function:       outputEnzCutter                                                                                           #
#   Description:    Outputs the EnzCutter result                                                                              #
#   Usage:          outputEnzCutter([Accession],[Comma separated list of enzymes], [Context], [CGI object])                   #
#                   Context                                                                                                   #
#                    0 = Nothing from the POST                                                                                #
#                    1 = "Gene" name found, could be a sequence                                                               #
#                    2 = Result                                                                                               #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub outputEnzCutter {
    my ($gene, $enzymes, $context, $cgi) = @_;
    my (%EnzCutter_Result, $EnzCutter_Result_ref);
    
    if (0 == $context or 1 == $context) {
        header(0 ,$cgi);
        EnzCutter_HTML($context, $gene);
        footer();
    } elsif (2 == $context) {
        #Do an EnzCutter cut
        %EnzCutter_Result = EnzCutter::doCut($gene,$enzymes);
        $EnzCutter_Result_ref = \%EnzCutter_Result;
        
        header(0 ,$cgi);
        my @seq = $gene =~ /(.{1,70})/g;
        print "<h2 class=\"center\">EnzCutter Results</h2>\n<br /><p>Sequence used:</p>\n<pre>";
        foreach my $seqs (@seq){
            if (length($seqs) > 1) {
                print "<p class=\"sequence\">$seqs</p>";
            }   
        }
        print "</pre>\n";
        EnzCutter_Output($EnzCutter_Result_ref);
        footer();
    }

}
###############################################################################################################################
#   Function:       EnzCutter_HTML                                                                                            #
#   Description:    Outputs the EnzCutter search page                                                                         #
#   Usage:          outputEnzCutter([context],[Accession])                                                                    #
#                   Context                                                                                                   #
#                    0 = Nothing from the POST                                                                                #
#                    1 = "Gene" name found, could be a sequence                                                               #
#                    2 = Result                                                                                               #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub EnzCutter_HTML {
    my $context = $_[0];
    my $gene = $_[1];
    print "<h2 class=\"center\">EnzCutter</h2>";
    print "<form method=\"post\" action=\"enz_cutter.pl\">\n";
    if (0 == $context) {
        print "<h3>Sequence</h3><p>Please use a DNA sequence or an Accession Number</p>\n";
        print "<textarea type=\"text\" name=\"gene\" id=\"EnzCutter_textarea\" autofocus=\"autofocus\" cols=\"40\" rows=\"4\" style=\"width:400px\"></textarea><br />\n";
    } elsif (1 == $context) {
        print "<h3>Sequence</h3><p>Using <span class=\"bold\">$gene</span></p>\n";
        print "<input type=\"hidden\" value=\"$gene\" name=\"gene\" />\n";
    }
    #Get the res
    print "<h3>Avaliable Restriction Enzymes</h3>\n";
    my %RES = ChromoDB::GetRES();
    foreach my $res (keys (%RES)){
        print "<input type=\"checkbox\" name=\"enzymes\" value=\"$res\"/>$res \n<br />";
    }
    print <<__HTML;
    <h3>Custom Input</h3>
    <p>Optional: Enter a custom enzymatic cut sequence using: <span class="bold">A|AAAA</span> and separate with commas.</p>
        <input type=\"text\" name=\"enzymes\" rows=\"1\"/><br /><br /><br />
        <input type=\"submit\" value=\"Submit\" />
        <input type=\"reset\" value=\"Reset\" />
    </form>
__HTML
}
###############################################################################################################################
#   Function:       EnzCutter_Output                                                                                          #
#   Description:    Outputs the individual EnzCutter Results                                                                  #
#   Usage:          EnzCutter_Output([Result Hash reference])                                                                 #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub EnzCutter_Output{
    my ($EnzCutter_Ref) = @_;
    my %EnzCutter_Result = %{$EnzCutter_Ref};
    foreach my $enz_results (keys ($EnzCutter_Result{"result"})){
        print "<h3 id=\"EnzCutter_results_h3\">$enz_results</h3>\n";
        foreach my $enzymes (keys ($EnzCutter_Result{"result"}{$enz_results})){
            my $count = 1;
            if ($enzymes eq "error"){
                print "<div id=\"EnzCutter_results_div\"><h4>No Cuts</h4></div>\n";
            } else {
                    my @cut_forw = split (/[,\||]/ , $EnzCutter_Result{"result"}{$enz_results}{$enzymes}{"sequence-forward"});
                    my @cut_rev  = split (/[,\||]/ , $EnzCutter_Result{"result"}{$enz_results}{$enzymes}{"sequence-reverse"});
                    my $spaces   = "&nbsp;" x (length($cut_forw[2])-1);

                    my $cut_forw_disp = "<span class=\"red-b\">$cut_forw[0]</span><span class=\"blue blue-b\">$cut_forw[1]</span><span class=\"bold\">$spaces|</span><span class=\"blue blue-b\">$cut_forw[2]</span><span class=\"red-b\">$cut_forw[3]</span>";
                    my $cut_rev_disp = "<span class=\"red-b\">$cut_rev[0]</span><span class=\"blue blue-b\">$cut_rev[1]</span><span class=\"bold\">|$spaces</span><span class=\"blue blue-b\">$cut_rev[2]</span><span class=\"red-b\">$cut_rev[3]</span>";
                    print <<__CUT;
                    <div id="EnzCutter_results_div"><h4>Cut $count</h4>
                        <div id="seq-for" class="sequence">5\'$cut_forw_disp 3\'</div> 
                        <div id="seq-rev" class="sequence">3\'$cut_rev_disp 5\'</div> 
                        <div id="seq-cut"><span>Cut used </span><span class="bold">$EnzCutter_Result{"result"}{$enz_results}{$enzymes}{"cut"}</span></div> 
                        <div id="seq-location"><span>Location </span><span class="bold">$EnzCutter_Result{"result"}{$enz_results}{$enzymes}{"location"}</span></div> 
                    </div>
__CUT
            $count++;
            }
        }
    }
}
###############################################################################################################################
#   Function:       header                                                                                                    #
#   Description:    Outputs the page headers                                                                                  #
#   Usage:          header([Count of results],[CGI object])                                                                   #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub header {
    my ($count, $cgi) = @_;
    print $cgi->header();
    print <<__HTML;
<!DOCTYPE HTML>
<html>
    <head>
        <meta charset="utf-8">
        <title>12Chrom</title>
        <link href="../css/style.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1/themes/smoothness/jquery-ui.css">
        <link rel="icon" type="image/png" href="../img/favicon.png" />
    </head>
    <body>
    <div class="navbar-wrapper">
        <div class="navbar-inner-wrapper">
            <div id="home" class="header pointer">
            <h1>12Chrom</h1>
            </div>
            <span class="subheader">Chromosome 12 Analysis Tool</span>
            <div class="navbar">
                <div class="item" id="home">
                    <a href="../fallback/">Home</a>
                </div>
                <div class="item">
                    <a href="../cgi-bin/enz_cutter.pl" id="EnzCutter_open">EnzCutter</a>
                </div>
                <div class="item">
                    <a href="../help/index.html" id="help_open" target="_blank">Help</a>
                </div>
                <div class="item">
                    <a href="fallback/contact.html" id="contact_open">Contact </a>
                </div>
                        
            </div>
        </div>
    </div>
    <div class="wrapper">
        <div id="content" style="display:block;">
__HTML
    if (defined($count) and $count > 0) {
        print <<__HTML2;
            <div class="titles-fixed" id="titles" style="position:relative; top:64px;"><div class="title title-acc unsorted" id="namesort">Accession</div><div class="title title-product unsorted" id="productsort">Protein Product</div><div class="title title-diagram">Gene Layout</div><div class="title title-len unsorted" id="lengthsort">Length</div><div class="title title-loc unsorted" id="locationsort">Location</div></div>
            <div class="center result-spacer"><h2>$count Results</h2></div>
            <div id=\"result-wrapper\">
__HTML2
    }
}
###############################################################################################################################
#   Function:       result                                                                                                    #
#   Description:    Outputs a search result                                                                                   #
#   Usage:          result([Result hash],[Result hash key])                                                                   #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub result {
    my ($resultRefLocal, $key) = @_;
    my %result = %{$resultRefLocal};
    print <<__HTML;
    <div class="result">
        <div class="result-div acc">
            <span id="acc"><div class="red pointer underline" id="single_open"><a href="../cgi-bin/return_single.pl?gene=$key">$key</a></div><span id="single_id">$result{$key}{"GeneName"}</span></div>
        <div class="result-div product" style="width:322px;"><span id="product">$result{$key}{"ProteinName"}</span></div> 
        <div class="result-div product" id="chart_div" style="width:322px;">Not avaliable in fallback mode</div> 
        <div class="result-div link"><span id="length">$result{$key}{"GeneLength"}</span></div> 
        <div class="result-div link"><span id="location">$result{$key}{"ChromosomeLocation"}</span></div> 
    </div>
__HTML

}
###############################################################################################################################
#   Function:       error                                                                                                     #
#   Description:    Outputs error HTML                                                                                        #
#   Usage:          error([result hash ref],[Key])                                                                            #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub error {
    my ($resultRefLocal, $key) = @_;
    my %result = %{$resultRefLocal};
    print <<__HTML;
    <div>
        <h2>There was an error</h2>
        <p>$key</p>
    </div>
__HTML
}
###############################################################################################################################
#   Function:       footer                                                                                                    #
#   Description:    Outputs the page footer                                                                                   #
#   Usage:          footer()                                                                                                  #
#   Returns:        HTML                                                                                                      #
########################################################################################################################################################
sub footer{
    print <<__HTML;
            </div> 
        </div>
    </div>
    </body>
</html>
__HTML
}
1;
