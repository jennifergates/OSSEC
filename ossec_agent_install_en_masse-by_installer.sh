#!/bin/bash
##########################################
#  ossec_install_agent_enmasse.sh script to install the ossec agent and configure it remotely. requires agent 
# installer files with the edited preloaded-vars.conf file archived with it for unattended install and password 
# to be entered interactively when run on. serverlist.txt should be one username:IP address:fqdn:yum or apt  per line for each 
# linux box to have agent installed on.	Ex: root:1.1.1.1:ws1-01.lab.name.net:yum			 
##########################################

if [ "$#" -lt 2 ];then
	echo "Usage: install_ossec_agent.sh /path/to/ssh_key /path/to/customAgent.tar.gz /path/to/serverlist.txt"
	
else	
	for LINE in $(cat $3); do

		KEY=$1
		TAR=$2
		USERNAME=${LINE%:*}
		USERNAME=${USERNAME%:*}
		USERNAME=${USERNAME%:*}
		HOST=${LINE#*:}
		HOST=${HOST%:*}
		FQDN=${HOST#*:}
		HOST=${HOST%:*}
		INSTALLER=${LINE##*:}
	
		echo "________________________________"
		echo "${USERNAME}@${HOST} with $INSTALLER"	
		echo "________________________________"
		echo "Using ${USERNAME} and ${KEY}, to connect to ${HOST} / ${FQDN} and install the ossec agent from ${TAR}."
		echo "SSH key passphrase and user password may need to be entered for each command."
		echo ""
		echo "[ ] Copying ${TAR} to host. May prompt for ssh key passphrase."
		scp -i $KEY $TAR ${USERNAME}@${HOST}:/tmp/ossec-hids-LS17-2.8.3.tar.gz
	
		echo "[ ] Extracting ${TAR} to /tmp/ on ${HOST}. May prompt for ssh key passphrase."
		ssh -i $KEY ${USERNAME}@${HOST} 'tar -zxf /tmp/ossec-hids-LS17-2.8.3.tar.gz -C /tmp/'
	
		if [ $INSTALLER = "apt" ] || [ $INSTALLER = "APT" ] || [ $INSTALLER = "Apt" ]; then
			echo "[ ] Installing prerequisites with apt and running unattended install. Prompts for ssh key passphrase and user's password for sudo command."
			ssh -i $KEY ${USERNAME}@${HOST} -tt 'export DEBIAN_FRONTEND=noninteractive && sudo apt-get install --assume-yes'
			ssh -i $KEY ${USERNAME}@${HOST} -tt 'export DEBIAN_FRONTEND=noninteractive && sudo apt-get install build-essential libssl-dev --assume-yes && cd /tmp/ossec-hids-LS17-2.8.3 && sudo ./install.sh && sudo /var/ossec/bin/agent-auth -A ${FQDN} -m 10.11.5.2 -p 1515 && sudo /var/ossec/bin/ossec-control restart'
		
		else 
			echo "[ ] Installing prerequisites with yum and running unattended install. Prompts for ssh key passphrase and user's password for sudo command."	
			ssh -i $KEY ${USERNAME}@${HOST} -tt 'export DEBIAN_FRONTEND=noninteractive && yum install -y openssl-devel && cd /tmp/ossec-hids-2.8.3 && ./install.sh && /var/ossec/bin/agent-auth -A ${FQDN} -m 10.11.5.2 -p 1515 && /var/ossec/bin/ossec-control restart'
		fi
		echo ""
done

fi


exit 0
