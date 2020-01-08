#!/bin/bash
pyscript=$(pgrep -f 'python /usr/local/openvpn_as/port80redirect.py')
echo $pyscript
#check variable for domain name is Set
check_pyscript () {
    if [ -z "$pyscript" ]; then
        printf "Variable is Empty"
        exit 1,
    else
        printf "Variable is $domain"
	kill_loop
    fi
}
kill_loop () {
    for PID in $pyscript; do
        printf "\nKilling $PID..."
        kill $PID
    done
}
kill_openvpn () {
    systemctl stop openvpnas
}
cert_renew () {
    certbot renew
}
restore_services () {
    sudo systemctl start openvpnas
    screen -dmS port80redirect /usr/bin/python /usr/local/openvpn_as/port80redirect.py
}
printf "\nChecking to see if pyscript is running..."
check_pyscript
printf "\nKilling OpenVPN Access Server..."
kill_openvpn
printf "\nRenewing Certificates...\n"
cert_renew
printf "\nRestoring Services\n"
restore_services
exit 0
