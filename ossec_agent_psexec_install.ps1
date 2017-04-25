<#
    .Synopsis
        This script will install the ossec agent on a remote system using psexec to run commands on the system
    .Description
        This script takes an input file that lists the windows computers by IP and hostname. It also requires the 
		path to client.keys files for each computer on the list. It also 
		
		The script installs the Windows OSSEC agent silently, copies the host's <hostname>_client.keys and ossec.conf 
		files to the program's folder, and then starts the ossec agent service.
		
    .Example
        ./ossec_agent_psexec_install.ps1 -computers_file mycomputers.txt -keys C:\ossec_keys\ -exe ossec-agent-win32-2.8.3.exe 
		-config ossec.config

    .Parameter computers_file
        file with list of computer IPs and hostnames to install the agent onto
	.Parameter keys
        path to the <hostname>_client.keys files
	.Parameter exe
        ossec agent installer file
	.Parameter config
        path to the ossec config file
    .Notes
        NAME: ./ossec_agent_psexec_install.ps1
        AUTHOR: Jennifer Gates
        VERSION: 1.00
        LASTEDIT: 20 April 2017
        CHANGELOG:
            1.00 - initial script 
    
        Output Colors:
        White - Input Required
        Cyan - Informational
        Yellow - Warning
        Red - Error

#>
#-------------------------------- Parameters --------------------------------#

Param(
	[Parameter(Mandatory=$True)]
	[string] $computers_file,
	
	[Parameter(Mandatory=$True)]
	[string] $keys,
	
	[Parameter(Mandatory=$True)]
	[string] $exe,
	
	[Parameter(Mandatory=$True)]
	[string] $config
)


#-------------------------------- Variables --------------------------------#


$cred = get-credential
$pass = $cred.getnetworkcredential().password
$user = $cred.username
$output = "ossec_installs.txt"
$PFExists = $False
$PF86Exists = $False
$ProgramDir = "not program files?"

#Check if input file exists. Exit if not.
$FileExists = Test-Path $computers_file
if($FileExists -eq $False) {
	write-host "$computers_file does not exist."  -foregroundcolor red
	exit
} 

#import computer hostname,IP from input file	
$computers = (Get-Content $computers_file)
#write-host $computers[0]

write-host "Output logged to $output." -foregroundcolor yellow

# loop through each computer and install ossec agent, copy files, start service
foreach ($remote in $computers)
{
	$remote = $remote.split(",")
	$hostname = $remote[0]
	$ip = $remote[1]
	$keyfile = $hostname + "_client.keys"
	
	#write-host $keyfile
	
	# install ossec-agent.exe
	write-host "[ ] Installing on $ip with $hostname" -foregroundcolor white
	"Installing on $ip with $hostname" | out-file $output -append
    
	& C:\Windows\System32\net.exe use \\$ip\C$ $pass /user:$user /persistent:no
	
	#check if Program Files or Program Files (x86)
	$PFExists = test-path "\\$ip\C$\Program Files\" 
	
	if ($PFExists -eq $True) {
		$ProgramDir = "Program Files"
		} 
	$PF86Exists = test-path "\\$ip\C$\Program Files (x86)\"
	if ($PF86Exists -eq $True) {
		$ProgramDir = "Program Files (x86)"
		}
	
	write-host $ProgramDir
	
	# test if already installed
	$FileExists =test-path "\\$ip\c$\$ProgramDir\ossec-agent\ossec-agent.exe"
	if($FileExists -eq $True) {
		write-host "     $ip already has ossec-agent installed. Continuing." -foregroundcolor yellow | out-file $output -append
	} else {
		
		try {		
			& C:\Users\Administrator\Desktop\SysInternals\PsExec.exe \\$ip -u $user -p $pass -c ossec-agent-win32-2.8.3.exe /S -accepteula >> $output
		} 
		catch {
			write-host $_ 
			write-host "$_  occured installing the agent on $ip - $hostname "| out-file $output -append
			continue
		}
	}
	
	# copy config file to correct location.
	write-host "[ ] Copying $config" -foregroundcolor white
	"Copying $config" | out-file $output -append
	try {
		copy-item -path "\\$ip\c$\$ProgramDir\ossec-agent\ossec.conf" -destination "\\$ip\c$\$ProgramDir\ossec-agent\ossec-conf.bak" -force >> $output
		copy-item -path $config -destination "\\$ip\c$\$ProgramDir\ossec-agent\ossec.conf" -force >> $output
	}
	catch {
		write-host $_ 
		write-host $error[0]
		write-host "$_  occured copying the config file on $ip - $hostname "| out-file $output -append
		continue
	}
	
	# copy corresponding host client.keys file 
	if($keys.substring($keys.length-1) -eq "\") {
		$keys = $keys.substring(0,$keys.length-1)
		}
	
	$keyfile = $keys + "\" + $hostname + "_client.keys"
	write-host "[ ] Copying $keyfile to $hostname" -foregroundcolor white
	"Copying $keyfile to $hostname" | out-file $output -append
	try {
		copy-item -path $keyfile -destination "\\$ip\c$\$ProgramDir\ossec-agent\client.keys" -force >> $output
		}
	catch {
		write-host $_ 
		write-host "$_  occured copying the client_keys file on $ip - $hostname "| out-file $output -append
		continue
	}
	# start service
	write-host "[ ] Starting ossec-agent service" -foregroundcolor white
	"Starting ossec-agent service" | out-file $output -append
	get-service -computer $ip "OSSEC HIDS" | set-service -status running
	get-service -computer $ip "OSSEC HIDS" | out-file $output -append
	
	& C:\Windows\System32\net.exe use /delete \\$ip\C$
	"____________________________________________" | out-file $output -append
}
