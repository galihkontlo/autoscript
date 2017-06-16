#!/bin/bash

if [ $USER != 'root' ]; then
	echo "Anda harus sebagai root"
	exit
fi

if [ ! -e /dev/net/tun ]; then
    echo "TUN/TAP belum diaktifkan :V"
    exit
fi

# Try to get our IP from the system and fallback to the Internet.
# I do this to make the script compatible with NATed servers (lowendspirit.com)
# and to avoid getting an IPv6.
#IP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$IP" = "" ]; then
        IP=$(wget -qO- ipv4.icanhazip.com)
fi

if [ -e /etc/openvpn/server.conf ]; then
	while :
	do
	clear
		echo "OVPN sudah terinstal"
		echo "Apa yang ingin anda lakukan?"
		echo ""
		echo "1) Hapus ovpn"
		echo "2) Exit"
		echo ""
		read -p "Select an option [1-2]:" option
		case $option in
			1) 
			apt-get remove --purge -y openvpn
			rm -rf /etc/openvpn
			rm -rf /usr/share/doc/openvpn
			sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0/d' /etc/rc.local
			echo ""
			echo "OpenVPN DIHAPUS !"
			exit
			;;
			2) exit;;
		esac
	done
else
	echo 'Selamat Datang di quick OpenVPN installer'
	echo "Created by AdityaWg"
	echo ""
	# OpenVPN setup and first user creation
	echo "Alamat IPv4 yang ingin diinstall OpenVPN?"
	echo "listening to."
	read -p "IP address: " -e -i $IP IP
	echo ""
	echo "Port untuk OpenVPN UDP?"
	read -p "Port: " -e -i 1195 PORT
	echo ""
	echo "Port untuk OpenVPN TCP?"
	read -p "Port: " -e -i 5555 PORT2
	echo ""
	echo "Sebutkan namamu untuk cert klien"
	echo "Silakan, gunakan satu kata saja, tidak ada karakter khusus"
	read -p "Nama Client Ovpn UDP: " -e -i client-udp CLIENT
	echo ""
	echo "Sebutkan namamu untuk cert klien"
	echo "Silakan, gunakan satu kata saja, tidak ada karakter khusus"
	read -p "Nama Client Ovpn TCP: " -e -i client CLIENT2
	echo ""
	echo "Oke, itu semua saya butuhkan. Saya siap untuk setup OpenVPN server Anda sekarang :*"
	read -n1 -r -p "Tekan sembarang tombol untuk melanjutkan,,..."
	apt-get update
	apt-get install openvpn iptables openssl -y
	cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn
	# easy-rsa isn't available by default for Debian Jessie and newer
	if [ ! -d /etc/openvpn/easy-rsa/2.0/ ]; then
		wget --no-check-certificate -O ~/easy-rsa.tar.gz https://github.com/OpenVPN/easy-rsa/archive/2.2.2.tar.gz
		tar xzf ~/easy-rsa.tar.gz -C ~/
		mkdir -p /etc/openvpn/easy-rsa/2.0/
		cp ~/easy-rsa-2.2.2/easy-rsa/2.0/* /etc/openvpn/easy-rsa/2.0/
		rm -rf ~/easy-rsa-2.2.2
	fi
	cd /etc/openvpn/easy-rsa/2.0/
	# Let's fix one thing first...
	cp -u -p openssl-1.0.0.cnf openssl.cnf
	# Bad NSA - 1024 bits was the default for Debian Wheezy and older
	#sed -i 's|export KEY_SIZE=1024|export KEY_SIZE=2048|' /etc/openvpn/easy-rsa/2.0/vars
	# Create the PKI
	. /etc/openvpn/easy-rsa/2.0/vars
	. /etc/openvpn/easy-rsa/2.0/clean-all
	# The following lines are from build-ca. I don't use that script directly
	# because it's interactive and we don't want that. Yes, this could break
	# the installation script if build-ca changes in the future.
	export EASY_RSA="${EASY_RSA:-.}"
	"$EASY_RSA/pkitool" --initca $*
	# Same as the last time, we are going to run build-key-server
	export EASY_RSA="${EASY_RSA:-.}"
	"$EASY_RSA/pkitool" --server server
	# Now the client keys. We need to set KEY_CN or the stupid pkitool will cry
	export KEY_CN="$CLIENT"
	export EASY_RSA="${EASY_RSA:-.}"
	"$EASY_RSA/pkitool" $CLIENT
	# DH params
	. /etc/openvpn/easy-rsa/2.0/build-dh
	# Let's configure the server
  
cat > /etc/openvpn/server.conf <<-END
port $PORT
proto udp
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh1024.pem
plugin /usr/lib/openvpn/openvpn-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
keepalive 5 30
cipher AES-128-CBC
comp-lzo
persist-key
persist-tun
status server-vpn.log
verb 3
END
cat > /etc/openvpn/server-tcp.conf <<-END
port-share 127.0.0.1 109
port $PORT2
proto tcp
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh1024.pem
plugin /usr/lib/openvpn/openvpn-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
keepalive 5 30
cipher AES-128-CBC
comp-lzo
persist-key
persist-tun
status server-vpn.log
verb 3
END
  
  cd /etc/openvpn/easy-rsa/2.0/keys
	cp ca.crt ca.key dh1024.pem server.crt server.key /etc/openvpn
	# Enable net.ipv4.ip_forward for the system
	sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
	# Set iptables
	if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
      		iptables -t nat -A POSTROUTING -o venet0 -j SNAT --to-source $IP
	else
      		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
      		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
			iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -j SNAT --to $IP
      		iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o eth0 -j MASQUERADE
	fi	
	sed -i "/# By default this script does nothing./a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" /etc/rc.local
	sed -i "/# By default this script does nothing./a\iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -j SNAT --to $IP" /etc/rc.local
	iptables-save
	# And finally, restart OpenVPN
	/etc/init.d/openvpn restart
	# Let's generate the client config
	mkdir ~/ovpn-$CLIENT
	# Try to detect a NATed connection and ask about it to potential LowEndSpirit
	# users
	EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
	if [ "$IP" != "$EXTERNALIP" ]; then
		echo ""
		echo "Looks like your server is behind a NAT!"
		echo ""
		echo "If your server is NATed (LowEndSpirit), I need to know the external IP"
		echo "If that's not the case, just ignore this and leave the next field blank"
		read -p "External IP: " -e USEREXTERNALIP
		if [ $USEREXTERNALIP != "" ]; then
			IP=$USEREXTERNALIP
		fi
	fi
	# IP/port set on the default client.conf so we can add further users
	# without asking for them

cat >> ~/ovpn-$CLIENT/$CLIENT.conf <<-END
client
proto udp
persist-key
persist-tun
dev tun
pull
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
;redirect-gateway
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
route-delay 2
remote $IP $PORT
;http-proxy-retry
;http-proxy $IP 80
cipher AES-128-CBC
END
cat >> ~/ovpn-$CLIENT/$CLIENT2.conf <<-END
client
proto tcp
persist-key
persist-tun
dev tun
pull
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
;redirect-gateway
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
route-delay 2
remote $IP $PORT2
;http-proxy-retry
;http-proxy $IP 80
cipher AES-128-CBC
END
  
  cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt ~/ovpn-$CLIENT
	cd ~/ovpn-$CLIENT
	cp $CLIENT.conf $CLIENT.ovpn
	cp $CLIENT2.conf $CLIENT2.ovpn
	echo "<ca>" >> $CLIENT.ovpn
	cat ca.crt >> $CLIENT.ovpn
	echo -e "</ca>\n" >> $CLIENT.ovpn
	echo "<ca>" >> $CLIENT2.ovpn
	cat ca.crt >> $CLIENT2.ovpn
	echo -e "</ca>\n" >> $CLIENT2.ovpn
	cp $CLIENT.ovpn $CLIENT2.ovpn /home/vps/public_html/
	#cp $CLIENT.ovpn $CLIENT2.ovpn /root
	cd ~/
	rm -rf ovpn-$CLIENT
	echo ""
	echo "Selesai!"
	echo ""
	echo "Your client config is available at ~/ovpn-$CLIENT.tar.gz"
fi
  
