#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
uname=bssh-`</dev/urandom tr -dc X-Z0-9 | head -c4`	
aktif=1
pass=`</dev/urandom tr -dc X-Z0-9 | head -c4`
	today="$(date +"%Y-%m-%d")"
	expire=$(date -d "$aktif days" +"%Y-%m-%d")
	useradd -M -N -s /bin/false -e $expire $uname
	echo $uname:$pass | chpasswd
echo -e "-------------[Trial Akun]-------------"
echo -e "Host: $myip" 
echo -e "Username: $uname "
echo -e "Password: $pass"
echo -e "Port: 22507,1922,443,80,22,143"
echo -e "Squid: 8000,8080,3128"
echo -e "Ovpn : http://$myip:81/client.ovpn"
echo -e "--------------------------------------"
