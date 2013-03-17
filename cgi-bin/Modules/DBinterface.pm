package DBinterface;

use DBI; # Comment out for SOAP Testing


# Subroutines



# Database facing

##########################################################################################################
#
# queryRun - Takes a MySQL search string, returns the result from the query in an array
#
##########################################################################################################
sub queryRun{

	# Get query string from function argument
	my $sqlQuery = $_[0];
	
	# Array to hold output
	my @rowData;
	
	# Attempt to connect to database 
	my $hDb = DBinterface::databaseConnect();
	if( undef eq $hDb ){
		# Could not connect return undefind
		return undef;
	}
	
	# Get a handle to the executing statement
	my $queryRows = $hDb->prepare($sqlQuery);
	
	# Run query
	if($queryRows->execute)
	{
		if (!$queryRows )
		{
			$hDb->errstr;
			return 'ERROR:DB_QUERY';
		}else{
			# Fetch all available rows from DB
			while(my @data = $queryRows->fetchrow_array){
				push(@rowData, @data);
			}	
		}
		$hDb->disconnect();
		
		if(isArrayEmpty(@rowData) eq TRUE){
			return 'NO_DATA';
		}else{
			# Return data in raw array form, let caller extract the required information
			return @rowData if wantarray;
		}
	}
}


# sanSearch - Takes as search string and returns a sanitized search string
sub sanSearch( $ ){
	return 1;
}

##########################################################################################################
#
# getIdentifier - Takes an indentifer and returns an indentifer that complies with the DB column names.
#
##########################################################################################################
sub getIdentifier{
	
	# Assumes that a valid string has been passed (ChromoDB checks this)
	my ($id, $idType) = $_[0], undef;
	
	# Attempt to match the input name to the a column id
	if( $id eq "GeneID" ) {
		$idType = "geneId";
	}elsif($id eq "ProteinProduct"){
		$idType = "proteinName";
	}elsif($id eq "AccessionNumber"){
		$idType = "accessionNo";
	}elsif($id eq "ChromosomeLocation"){
		$idType = "chromLoc";
	}elsif($id eq "GeneSeq"){
		$idType = "geneSeq";
	}elsif($id eq "ProteinSeq"){
		$idType = "proteinSeq";
	}else{
		# If nothing matched return error
		return 'ERROR:UNRECOGNIZED_ID';
	}
	
	# If a match is found then this will return the match.
	return $idType;
}

##########################################################################################################
#
# querySearch - Takes a search string and type, returns comma separated list of search results
#
##########################################################################################################
sub querySearch{
	
	# Get the function parameters, assumes valid non-zero string and valid identifier input
	my ($searchString, $idType) = @_;
	
	# Run search query **$searchstring must be in quotes***
	my $sqlQuery = "SELECT accessionNo, geneId FROM gene WHERE $idType='$searchString'";
	
	# Run query
	my @id = DBinterface::queryRun($sqlQuery);
	
	if(@id eq undef){
		return 'ERROR:NO_DB_CONNECTION';
	}
	
	if(@id[0] eq 'NO_DATA'){
		return 'ERROR:NO_DB_MATCHES';
	}
	
	# Create comma separated string
	#my $string = join(",",@id);
	
	my @validEntries;
	
	for(my $i = 0; $i < scalar(@id); $i++ ){
		# Concatenate and copy into new array
		my $entry = join(":",$id[$i],$id[$i+1]);
				
		# Enter valid entry in to new array
		push(@validEntries, $entry);
				
		# Increment past the next array entry 
		$i++; 
	}
	
	return @validEntries;
	
}  
##########################################################################################################
#
# queryColumn - Takes a column id and returns elements of a single column
#
##########################################################################################################
sub queryColumn{

	# Assumes the identifer passed will be in the correct form as this should only every be called from code
	# so no need to check it.
	
	my $columnId = $_[0];
	
	# Define query for specified colum
	my $sqlQuery = "SELECT accessionNo, $columnId FROM gene";
	
	# Run query
	my @id = DBinterface::queryRun($sqlQuery);
	
	# Check for empty Db coonection and empty columns
	if( undef eq @id ){
		return 'ERROR:NO_DB_CONNECTION';
	}	
	
	# If element in the array are valid
	if(@id[0] eq 'NO_DATA'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}else{
		# Array to hold the valid entries from the DB
		my @validEntries;
	
		# Step through array and copy over only valid entries
		for(my $i = 0; $i < scalar(@id); $i++){
		
			# Check that the next entry is not blank
			if(0 != length($id[$i+1]) ){
				# Concatenate and copy into new array
				my $entry = join(":",$id[$i],$id[$i+1]);
				
				# Enter valid entry in to new array
				push(@validEntries, $entry);
				
				# Increment past the next array entry 
				$i++; 
			}
			else{
				# Skip over current entry and next
				# as the accession has no corresponding entry
				$i++;
			}
		}
	
		# Create comma separated string
		#my $string = join(",",@validEntries);
		
		# Pass back string
		return @validEntries;
	}
}
###############################################################################################
#
# querySequence - Takes an accession number and returns the DNA sequence for it from the DB.
#
###############################################################################################
sub querySequence{
	
	# Store input accession numbers
	my ($accessionNo, $seqType) = @_;
	
	# Query to retireve the sequecne
	my $sqlQuery = "SELECT $seqType FROM gene WHERE accessionNo='$accessionNo'";
	
	# Run query and handle empty data
	my @seq = DBinterface::queryRun($sqlQuery);
	if( @seq[0] eq 'NO_DATA'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}else{
		# Copy data to string
		my $string = @seq[0];
		# Pass back data as string
		return $string;
	}
}


# findRES - Takes a RES name and an Id and returns a list of matches within the given identifer sequence.
sub findRES( $ $ ){
	return 1;
}

# addRES - Takes a DNA sequecne and a name for the restriction enzyme. Returns 1 on success 
# (has been added) or 0 on fail (cannot be added)
sub addRES( $$ ){
	return 1;
}

###############################################################################################
#
# buildCodingSeq - Takes an Id and returns an array with all the introns and exons in sequence.
#
###############################################################################################
sub buildCodingSeq{

	# Get accession number for DB lookup
	my $accessionNo = $_[0];
	
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuery = "SELECT featStart, featEnd FROM seqFeat WHERE accessionNo='$accessionNo'
	ORDER BY LENGTH(featStart)";
	
	# Fetch the exon coding sequence information from DB, array will progress as 
	# Type, start, stop then repeat for next item.
	my @tableRows = DBinterface::queryRun($sqlQuery);
	if (@tableRows eq 'NO_DATA'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}
	
	# Get the length of the sequence
	# Specify query includes start position and end position of exons from give accessionNo.
	my $sqlQuerySeqlength = "SELECT geneSeqLen FROM gene WHERE accessionNo='$accessionNo'";
	
	my @sequenceLength = DBinterface::queryRun($sqlQuerySeqlength);
	if (@sequenceLength eq 'NO_DATA'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}
	#print @sequenceLength;
	
	#foreach my $entry (@tableRows){
	#	print $entry,"\n";
	#}
	
	
	# Create comma separated string only for devlop purposes
	my $string = join(",",@tableRows);
	
	#print $string,"\n";
	
	# Read array and cut the sequence up according to the start stop sequence features,
	# assumes that MySQL has put items in correct order.  
	# If not may have to implement sort function
	
	# Array to hold final data that is passed back to caller
	my @CDSarray;
	
	# Used to track position in array
	my $tableRowIndex = 0; 
	
	
	# All entries are exons, all non-coding introns are inferred from the data and must 
	# be present in the final array.
	
	# Deal with first entry outside of loop as it is a bit inefficient to run the check
	# every iteration of the loop below.
	
	# Is first entry an exon? If so, does it start at one? 
	if( 1 == $tableRows[0] ){
	
		# If yes, then sequecne starts with exon.
		my $entry = join("","EXON;",$tableRows[0],":",$tableRows[1]);
		push(@CDSarray, $entry);
		
		# Offset the beginning of the array for the coming loop.
		$tableRowIndex = 2; 
		
		if(defined($tableRows[2])){
			# Set the segement follwing as an NCS
			my $ncsEntry = join("","NCS;",$tableRows[1]+1,":",$tableRows[2]-1);
			push(@CDSarray, $ncsEntry);
		}else{
			my $ncsEntry = join("","NCS;",$tableRows[1]+1,":",@sequenceLength);
			push(@CDSarray, $ncsEntry);
		}
		
	}else{
		# If no then infer an intron and calculate intron length, sequence begins with intron.
		my $entry = join("","NCS","0",":",$tableRows[0]-1);
		push(@CDSarray, $entry);
	}
	
	# Extract start and end positions of the exons, put them into array.
	for( my $i = $tableRowIndex; $i < scalar(@tableRows); $i++){
		
		my ($segStart, $segStop); 
		
		# Get start number of current exon
		$segStart = $tableRows[$i];
		
		# Increment again to next item
		$i++;
		
		# Extract stop position of exon 
		$segStop = $tableRows[$i];
		
		# Write the start/stop information into the string
		my $entry = join("","EXON;",$segStart,":",$segStop);
		push(@CDSarray, $entry);
	
		# Find distance between current exon and next and denote as NCS in array.
		if( defined($tableRows[$i+1]) )
		{
			my $ncsEntry = join("","NCS;",$tableRows[$i],":",$tableRows[$i+1]-1);
			push(@CDSarray, $ncsEntry);
		}else{
			my $ncsEntry = join("","NCS;",$segStop+1,":",@sequenceLength);
			push(@CDSarray, $ncsEntry);
		}
	}
	
	return @CDSarray;
}

##########################################################################################################
#
# databaseConnect - Takes database name, username, password and server name, returns handle to DB or undef.
# let the caller handle success and fail of connect.
#
##########################################################################################################
sub databaseConnect{
	
	# Defined the connection details to the database
	my $dbname = 'scouls01'; 
	my $user = 'scouls01';
	my $password = 'iwr8sh8vb'; 
	my $dbserver = 'localhost';
	
	#my $dbname = 'biocomp2'; 
	#my $user = 'c2';
	#my $password = 'coursework123'; 
	#my $dbserver = 'joes-pi.dyndns.org';
	
	# Specify the location and name of the database
	my $datasource = "dbi:mysql:database=$dbname;host=$dbserver;";
	
	
	# Attempt to connect to the database (turn off DBI error reporting )
	my $dbh = DBI->connect($datasource, $user, $password, {PrintError => 0});
	
	# If succesful connect return the handle if not return undefined
	# Note: connect only seems to care that password is present will still
	# return true if user is missing
	if( defined($dbh) )
	{
		# Return handle to database
		return $dbh;
	}else{
		# Show why DBI-connect failed
		#print DBI->errstr;
		return undef;
	}
}

##########################################################################################################
#
# isArrayEmpty - Takes an array as input and returns true if it is empty or false if not empty
#
##########################################################################################################
sub isArrayEmpty{
	# Get length of array loop through array and test if each entry is valid of empty
	# If all are empty then the coloumn is effectively empty.
	my @array = @_;
	my $arraySize = scalar(@array);
	
	for(my $i = 0; $i < scalar(@array); $i++){
		# If not zero length or is not equal to N/A trigger return
		if((length($array[$i])) && ($array[$i] ne 'N/A') )
		{
			return FALSE; # Has length or is equal to N/A
		}
	}
	# All item were zero length or N/A return true
	return TRUE;
}

sub returnArray(){
	my @array = {"one","two","three","four"};
	return @array;
}



# Constants

use constant FALSE => 1;
use constant TRUE => 0;

# Global variables

1;
