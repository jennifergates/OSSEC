# OSSEC
OSSEC files
agent.conf - put in /var/ossec/etc/shared/ to be pushed to all agents (linux and windows)
client-ossec.conf - rename ossec.conf and use in installer to place on each client. Just contains xml to talk to server.
decoder.xml - put in /var/ossec/etc for use with log analysis (ie. applocker logs)
edited_preloaded-vars.conf - rename preloaded-vars.conf and use with linux installer for unattended install
local_rules.xml - put in /var/ossec/rules on server. 
ossec.conf - put in /var/ossec/etc/ on Server. configures global and server settings.
