# OSSEC
<P>OSSEC files </P>
<b>agent.conf </b>- put in /var/ossec/etc/shared/ to be pushed to all agents (linux and windows) <br>
<b>client-ossec.conf </b>- rename ossec.conf and use in installer to place on each client. Just contains xml to talk to server.<br>
<b>decoder.xml </b>- put in /var/ossec/etc for use with log analysis (ie. applocker logs)<br>
<b>edited_preloaded-vars.conf </b>- rename preloaded-vars.conf and use with linux installer for unattended install<br>
<b>local_rules.xml </b>- put in /var/ossec/rules on server. <br>
<b>ossec.conf </b>- put in /var/ossec/etc/ on Server. configures global and server settings.<br>
