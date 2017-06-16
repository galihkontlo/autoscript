#!/bin/bash
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
if getent passwd $1 > /dev/null 2>&1; then
        echo $1:$2 | chpasswd
        echo -e "Penggantian password akun [$1] Sukses"
	     	echo -e ""
	    	echo -e "-----------------------------------"
	     	echo -e "Data Login:"
		echo -e "-----------------------------------"
	     	echo -e "Host/IP: $MYIP"
	    	echo -e "Dropbear Port: 443, 110, 109"
		echo -e "OpenSSH Port: 22, 143"
		echo -e "Squid Proxy: 80, 8080, 3128"
		echo -e "OpenVPN Config: http://$MYIP:81/client.ovpn"
		echo -e "Username: $1"
		echo -e "Password: $2"
	        echo -e "-----------------------------------"
else
        echo -e "GAGAL: User $1 tidak ada."
fi
