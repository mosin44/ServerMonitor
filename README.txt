This script will test whether a system is available via either HTTP or ICMP Ping.

I developed this to alert me when systems or components / appliances become unavailable at our church. (For example, a PC off-line because the power blipped and it got a boot failure).

In order to allow this script to run in an automated fashion, I had to store the e-mail credentials.

We use Office 365 for our e-mail hosting.  So I used the Export-Clixml method to create the credential file.

	$Credential | Export-CliXml -Path "PATHTOTHISSCRIPT\mailcreds.txt"
	
If you host on some other platform, YMMV.

The config file determines which IP addresses or host names are to be tested via HTTP, and which by PING.
NOTE: the lines to be tested by HTTP have HTTP in all caps in them.  Those to be tested by PING have PING in them. 
If you add other comment lines to the config file please ensure they have neither HTTP nor PING in them.   This will cause errors.

