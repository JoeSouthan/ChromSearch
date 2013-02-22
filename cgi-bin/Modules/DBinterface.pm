package DBinterface;

use DBI; # Comment out for SOAP Testing
use Test::More;

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
		$idType = "geneID";
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
	my $sqlQuery = "SELECT geneId FROM gene WHERE $idType='$searchString'";
	
	# Run query
	my @id = DBinterface::queryRun($sqlQuery);
	
	if(@id eq undef){
		return 'ERROR:NO_DB_CONNECTION';
	}
	
	if(@id[0] eq 'NO_DATA'){
		return 'ERROR:NO_DB_MATCHES';
	}
	
	# Create comma separated string
	my $string = join(",",@id);
	
	return $string;
	
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
	my $sqlQuery = "SELECT $columnId FROM gene";
	
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
		# Create comma separated string
		my $string = join(",",@id);
		
		# Pass back string
		return $string;
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
	
	# Get coding information from DB, this includes type, start position and end position
	# of exons, introns and non-coding sequences
	my $sqlQuery = "SELECT type, featStart, featEnd FROM seqFeat WHERE accessionNo='$accessionNo'
	ORDER BY featStart DESC";
	
	# Fetch the exon coding sequence information from DB, array will progress as 
	# Type, start, stop then repeat for next item.
	my @tableRows = DBinterface::queryRun($sqlQuery);
	if (@tableRows eq 'NO_DATA'){
		return 'ERROR:DB_COLUMN_EMPTY';
	}
	
	# Create comma separated string only for devlop purposes
	my $string = join(",",@tableRows);
	#print $string,"\n";
	
	# Read array and cut the sequence up according to the start stop sequence features,
	# assumes that MySQL has put items in correct order.  
	# If not may have to implement sort function
	
	# Array to hold final data that is presented back to website
	my @CDSarray;
	
	# Used to track position in array
	my $CDSindex = 0; 
	
	
	
	# All entries are either marked Exon or non-coding introns are inferred from the data and must 
	# be present in the final array.
	
	# Is first entry a non-coding sequence if so it will start at 1 as there is never non-coding within sequence
	# Sequence therefore begins with a non-coding sequence. 
	
	# Is first entry an exon? If so, does it start at one? 
	
	# If yes, then sequecne starts with exon.
	
	# If no then infer an intron and calculate intron length, sequecne begins with intron.
	
	
	
	# Extract start and end positions of each coding type, put them into array.
	for( my $i = 0; $i < scalar(@tableRows); $i++){
	
		my ($segType, $segStart, $segStop); 
		
		# Extract type 
		$segType = $tableRows[$i];
	
		# Move counter along one
		$i++; 
		
		# Get start number (next in the array)
		$segStart = $tableRows[$i];
		
		# Increment again to next item
		$i++;
		
		# Extract final stop position 
		$segStop = $tableRows[$i];
		
		# String to hold full identfier type of region
		my $regionCode = '';
		
		# Inspect and write string for array entry
		# Need to decide on exact 'TYPES' for these entries before proceeding
		
		if( 'E' eq $segType ){
			$regionCode = 'EXON:';
		}elsif( '5' eq $segType ){
			$regionCode = '5:';
		}elsif( '3' eq $segType ){
			$regionCode = '3:';
		}
		
		# Is sequence fragment complementry? 
		
		
		
		# Write the start/stop information into the string
		my $codedString = join "", $regionCode, $segStart, ":", $segStop;
		
		# Commit this to CDSarray 
		@CDSarray[$CDSindex] = $codedString;
		# Increment index in to array by one for next item
		$CDSindex++;
		
	}
	
	# Load in to array always start with first element as 
	
	#foreach my $val (@CDSarray){
	#	print $val,"\n";
	#}
	
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


# Constants

use constant FALSE => 1;
use constant TRUE => 0;

# Global variables

1;
