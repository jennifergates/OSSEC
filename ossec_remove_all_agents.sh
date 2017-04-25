#!/bin/bash
######
# This Script runs a list command on the existing clients added to the OSSEC server
# and then removes them, one by one, using the manage_agents CLI API and the agent
# IDs pulled from the list output. If successfully removes an agent, it restarts the
# OSSEC server service.  Run this on the server with root privileges.
######

clear

if [ ` id -u` -ne 0 ]; then
	echo "This script must be run as root or with sudo."
	exit 0
fi

echo "This script will remove all agents currently added to this OSSEC server."
echo "Type "Remove" to proceed."
read Continue

if [ $Continue = "Remove" ] ; then 
	/var/ossec/bin/manage_agents -l | awk '{print $2}' | sed 's/,$//' | sed '/^\s*$/d' > /tmp/ids
	while read -r var; do 
		if [ $var = "agents:" ]; then
			continue;
		fi
		if [ $var = "No" ]; then
			echo "No Agents to Remove";
			exit 0;
		else
			echo "Removing $var";
			/var/ossec/bin/manage_agents -r $var;
		fi 
	done < /tmp/ids ;
fi

echo "Restarting the OSSEC service"
/var/ossec/bin/ossec-control restart

#/var/ossec/bin/manage_agents -l
rm /tmp/ids
