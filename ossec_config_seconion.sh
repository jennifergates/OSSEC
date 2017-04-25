#!/bin/bash
##########################################
#
# Script to configure Security Onion for receiving OSSEC agent connections. It  
# configures the firewall, configures openSSL, starts the ossec-authd service, 
# and restarts ossec. 
##########################################


clear

if [ ` id -u` -ne 0 ]; then
	echo "This script must be run as root or with sudo."
	exit 0
fi

echo "Adding firewall rules for agents to communicate with the OSSEC server. "
echo "Enter an IP (1.2.3.4) or Subnet in CIDR notation (1.2.3.4/24)"
echo "or 'Done' when finished:"
read SUBNET

while [ $SUBNET != "Done" ]; do
	
	echo "[ ] Adding firewall rules"

	echo "[ ] Configuring firewall to allow agent additions/key auth"
	echo "[ ] Adding rule: ufw allow proto tcp from $SUBNET to any port 1515"
	ufw allow proto tcp from $SUBNET to any port 1515

	echo "[ ] Configuring firewall to allow agent data"
	echo "[ ] Adding rule: ufw allow proto udp from $SUBNET to any port 1514"
	ufw allow proto udp from $SUBNET to any port 1514
	
	echo " "
	echo "Enter an IP (1.2.3.4) or Subnet in CIDR notation (1.2.3.4/24)"
	echo "or 'Done' when finished:"
	
	read SUBNET
done
	
	ufw status 



echo " "
echo "[ ] Creating SSL key for server authentication. Enter certificate information when prompted."
echo " "
openssl genrsa -out /var/ossec/etc/sslmanager.key 2048
openssl req -new -x509 -key /var/ossec/etc/sslmanager.key -out /var/ossec/etc/sslmanager.cert -days 365


#Start listening for agents requesting to be added and issued a key
/var/ossec/bin/ossec-authd -p 1515 >/dev/null 2>&1 &
echo "[ ] Starting ossec-authd listening for clients to connect from agent-authd."

#Restart OSSEC service
/var/ossec/bin/ossec-control "restart"
echo "[ ] The ossec service has been restarted. Client's can now start sending data."
echo "[ ] Script complete"
