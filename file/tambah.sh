#!/bin/bash
clear
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
egrep "^$1" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
	echo "Username [$1] sudah ada!"
	exit 1
else
	today="$(date +"%Y-%m-%d")"
	expire=$(date -d "30 days" +"%Y-%m-%d")
	useradd -M -N -s /bin/false -e $expire $1
	echo $1:$2 | chpasswd
echo -e ""
echo -e ""
echo -e "-------------------------------------"
echo -e "Data Login :"
echo -e "-------------------------------------"
echo -e "Host: $MYIP" 
echo -e "Dropbear Port: 443,1922,22507,80"
echo -e "OpenSSH Port: 22,143"
echo -e "Squid Proxy: 3128,8000,8080"
echo -e "Ovpn Config: http://$MYIP:81/client.ovpn"
echo -e "Username: $1"
echo -e "Password: $2"
echo -e "Aktif Sampai: $(date -d "$AKTIF days" +"%d-%m-%Y")"
echo -e "-------------------------------------"
echo -e ""
fi
