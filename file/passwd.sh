#!/bin/bash
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
if getent passwd $1 > /dev/null 2>&1; then
        echo $1:$2 | chpasswd
        echo "Penggantian password akun [$1] Sukses"
	     	echo ""
	    	echo "-----------------------------------"
	     	echo "Data Login:"
		    echo "-----------------------------------"
	     	echo "Host/IP: $MYIP"
	    	echo "Dropbear Port: 443, 110, 109"
		    echo "OpenSSH Port: 22, 143"
		    echo "Squid Proxy: 80, 8080, 3128"
		    echo "OpenVPN Config: http://$MYIP:81/client.ovpn"
		    echo "Username: $1"
		    echo "Password: $2"
	      echo "-----------------------------------"
else
        echo -e "GAGAL: User $1 tidak ada."
fi
