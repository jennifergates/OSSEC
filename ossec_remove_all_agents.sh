#!/bin/bash
######
# This Script runs a list command on the existing clients added to the OSSEC server
# and then removes them, one by one, using the manage_agents CLI API and the agent
# IDs pulled from the list output. Run this on the server with root privileges.
######

clear

if [ ` id -u` -ne 0 ]; then
	echo "This script must be run as root or with sudo."
	exit 0
fi

echo "This script will remove all agents currently added to this OSSEC server."
echo "Type "Remove" to proceed."
read $Continue

if [ $Continue -eq "Remove"]; then 
	var/ossec/bin/manage_agents -l | awk '{print $2}' | sed 's/,$//' > /tmp/ids
	while read -r var; do 
		echo removing $var;
		sudo /var/ossec/bin/manage_agents -r $var; 
	done < /tmp/ids;
fi
	
