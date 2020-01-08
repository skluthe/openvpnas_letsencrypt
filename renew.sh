#!/bin/bash
#Stop OpenVPN Access Server
systemctl stop openvpnas 
#Kill HTTP Redirection (Optional)
kill$(pgrep -f 'python /usr/local/openvpn_as/port80redirect.py')'
#Renew the local certificates
certbot -q renew 
#Start OpenVPN Access Server Again
sudo systemctl start openvpnas
#Start HTTP Redirection (Optional)
screen -dmS port80redirect /usr/bin/python /usr/local/openvpn_as/port80redirect.py'
