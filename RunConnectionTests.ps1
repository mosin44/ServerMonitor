############################################################################################################################
# This script will do very basic testing to validate that certain resources are up and available                           #
# For IP addresses or host names in curllist.txt, the script will run curl to validate that a web server is running        #
# For IP addresses or host names in pinglist.txt, the script will run ping to determine whether the resource is reachable  #
# The script will write all failures to a file, then when the script completes, if there have been any failures it will    #
# e-mail the list of failures to the designated recipient(s).                                                              #
############################################################################################################################

############################################################################################################################
# Use Invoke-Webrequest to determine if webservers are all up and responding                                               #
############################################################################################################################

$PATH=Get-Location
$ConfigFile="$PATH\ServersToTest.txt"
$ErrorFile="$PATH\mailbody.txt"
$LOGFILE="$PATH\RunConnectionTests.log"
$TotalFails=0
copy MailHead.txt $ErrorFile
rm $LOGFILE
$RunDate=Get-Date
Add-content $LOGFILE $RunDate

Add-Content $LOGFILE "######################################################################"
Add-Content $LOGFILE "Beginning HTTP tests"
Add-Content $LOGFILE "######################################################################"

Foreach ($ServerLine in Get-Content $ConfigFile | Where { $_ -CMatch "HTTP"})
{
	Add-Content $LOGFILE "######################################################################"
	$pos = $ServerLine.IndexOf(" ")
	$IPAddress = $ServerLine.Substring(0, $pos)
	Add-Content $LOGFILE "Checking server $IPAddress via HTTP"
	Invoke-Webrequest $IPAddress  
	

	$RC=$?
	Add-Content $LOGFILE "Return Code $RC encountered when testing $IPAddress via HTTP"
	if ( $RC )
	{
	}
	else
	{
		$ERRORSTRING = "Webserver at IP address $IPAddress is not responding to Invoke-Webrequest"
		$TotalFails=$TotalFails+1
		Add-Content $ErrorFile $ERRORSTRING
		$SearchAddress=$IPAddress+" *HTTP"
		$SearchResult=select-string $SearchAddress $ConfigFile
		Add-Content $ErrorFile $SearchResult
	}
		
	
	

}

############################################################################################################################
# Use Test-Connection to determine if other machines are all up and responding                                             #
############################################################################################################################

$SectionDivider="######################################"
Add-Content $ErrorFile $SectionDivider
Add-Content $LOGFILE "######################################################################"
Add-Content $LOGFILE "Beginning PING tests"
Add-Content $LOGFILE "######################################################################"


Foreach ($ServerLine in Get-Content $ConfigFile | Where { $_ -CMatch "PING" })
{
	Add-Content $LOGFILE "######################################################################"
	$pos = $ServerLine.IndexOf(" ")
	$IPAddress = $ServerLine.Substring(0, $pos)
	Add-Content $LOGFILE "Checking server $IPAddress via Test-Connection"

	Test-Connection $IPAddress  


	$RC=$?
	Add-Content $LOGFILE "Return Code $RC encountered when testing $IPAddress via Test-Connection"
	if ( $RC )
	{
	}
	else
	{
		$TotalFails=$TotalFails+1
		$ERRORSTRING = "Machine at IP address $IPAddress is not responding to Test-Connection"
		Add-Content $ErrorFile $ERRORSTRING
		# I'm using grep to get the full line with it's comment out of the config file
		# I'm appending a space to the end of the search string so that a .1 address doesn't also get .100
		$SearchAddress=$IPAddress+" *PING"
		$SearchResult=select-string $SearchAddress $ConfigFile
		Add-Content $ErrorFile $SearchResult	}
		
	
	

}
############################################################################################################################
# Check if any errors were detected. If so, e-mail the error file.                                                         #
############################################################################################################################

if ( $TotalFails )
{
	$SubjectLine="ALERT $TotalFails errors testing RCOC systems at $RunDate"
	$ToAddress = 'italerts@reynoldsburgchurch.org'
	$FromAddress = 'rcocadmin@reynoldsburgchurch.org'
	$SmtpServer = 'smtp.office365.com'
	$SmtpPort = '587'
	$ErrorFile="$PATH\mailbody.txt"
	$CredFile="$PATH\mailcreds.txt"
	$EmailBody=[IO.File]::ReadAllText($ErrorFile)
	$mailparam = @{
		To = $ToAddress
		From = $FromAddress
		Subject = $SubjectLine
		Body = $EmailBody
		SmtpServer = $SmtpServer
		Port = $SmtpPort
		Credential = Import-CliXml -Path $CredFile
}

Send-MailMessage @mailparam -UseSsl
}
