#!/bin/bash
# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
source="https://raw.githubusercontent.com/AdityaWg/autoscript/master";

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list $source/file/sources.list.debian7
wget "http://www.dotdeb.org/dotdeb.gpg"
wget "http://www.webmin.com/jcameron-key.asc"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i venet0
service vnstat restart

# screenfetch
cd
wget $source/file/screeftech-dev
mv screeftech-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile
echo "date" >> .profile

# Web Server
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf $source/file/nginx.conf
mkdir -p /home/vps/public_html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /home/vps/public_html/index.html $source/file/index.txt
wget -O /etc/nginx/conf.d/vps.conf $source/file/vps.conf
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# badvpn
wget -O /usr/bin/badvpn-udpgw $source/file/badvpn-udpgw
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw $source/file/badvpn-udpgw64
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
# mrtg
wget -O /etc/snmp/snmpd.conf $source/file/snmpd.conf
wget -O /root/mrtg-mem.sh $source/file/mrtg-mem.sh
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl $source/file/mrtg.conf >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# port ssh
sed -i '/Port 22/a Port  143' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port  80' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
sed -i 's/#Banner/Banner/g' /etc/ssh/sshd_config
echo "Banner /etc/baner" >> /etc/ssh/sshd_config
service ssh restart

# dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 80 -p 1922 -p 22507"/g' /etc/default/dropbear
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="\/etc\/baner"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart
# upgrad
apt-get install zlib1g-dev
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2017.75.tar.bz2
bzip2 -cd dropbear-2017.75.tar.bz2  | tar xvf -
cd dropbear-2017.75
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restartgi

# VNSTAT
apt-get install vnstat -y
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# Ddos deflate
wget -O- https://raw.githubusercontent.com/stylersnico/nmd/master/debian/install.sh | sh
wget -O- https://raw.githubusercontent.com/stylersnico/nmd/master/debian/update.sh | sh

# fail2ban
apt-get -y install fail2ban;service fail2ban restart

# BAANER
wget -O /etc/baner $source/file/baner.txt

# squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf $source/file/squid.conf
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.820_all.deb"
dpkg --install webmin_1.820_all.deb;
apt-get -y -f install;
rm /root/webmin_1.820_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
apt-get -y -f install libxml-parser-perl
service webmin restart
service vnstat restart

# autoreboot
echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "* * * * * service dropbear restart" > /etc/cron.d/dropbear
echo "0 */12 * * * root /bin/bash /usr/bin/expdel" > /etc/cron.d/expdel
# ovpn
wget $source/file/ovpn.sh && bash ovpn.sh

# script
cd /usr/bin
wget -O tambah $source/file/tambah.sh
wget -O renew $source/file/renew.sh
wget -O pass $source/file/passwd.sh
wget -O hapus $source/file/hapus.sh
wget -O akun $source/file/akun.sh
wget -O bench "https://raw.githubusercontent.com/khairilg/script-jualan-ssh-vpn/master/bench-network.sh"
wget -O mem "https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py"
wget -O userlog $source/file/userlog.sh
wget -O expdel $source/file/expdel.sh
wget -O tendang $source/file/tendang.sh
wget -O trial $source/file/trial.sh
wget -O speedtest $source/file/speedtest_cli.py
echo "python /usr/bin/speedtest.py --share" | tee speedtest
wget -O speedtest $source/file/speedtest_cli.py
chmod +x tambah
chmod +x renew
chmod +x expdel
chmod +x speedtest
chmod +x speedtest_cli.py
chmod +x pass
chmod +x tendang
chmod +x trial
chmod +x mem
chmod +x bench
chmod +x hapus
chmod +x akun
chmod +x userlog

 # finishing
chown -R www-data:www-data /home/vps/public_html
service cron restart
service nginx start
service php-fpm start
service vnstat restart
service snmpd restart
service ssh restart
service openvpn restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile
rm /root/debian7.sh
rm -f /root/debian7.sh
rm /root/ovpn.sh
rm -f /root/ovpn.sh
history -c
