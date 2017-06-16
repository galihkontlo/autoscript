#!/bin/bash
cd
apt-get install make
cd
wget https://raw.githubusercontent.com/yusuf-ardiansyah/debian/master/shc-3.8.7.tgz
tar xvfz shc-3.8.7.tgz
cd shc-3.8.7
make
./shc -f /usr/bin/tambah
cd
mv /usr/bin/tambah.x /usr/bin/tambah
chmod +x /usr/bin/tambah
cd shc-3.8.7
make
./shc -f /usr/bin/renew
cd
mv /usr/bin/renew.x /usr/bin/renew
chmod +x /usr/bin/renew
cd shc-3.8.7
make
./shc -f /usr/bin/pass
cd
mv /usr/bin/pass.x /usr/bin/pass
chmod +x /usr/bin/pass
cd shc-3.8.7
make
./shc -f /usr/bin/hapus
cd
mv /usr/bin/hapus.x /usr/bin/hapus
chmod +x /usr/bin/hapus
cd shc-3.8.7
make
./shc -f /usr/bin/akun
cd
mv /usr/bin/akun.x /usr/bin/akun
chmod +x /usr/bin/akun
cd shc-3.8.7
make
./shc -f /usr/bin/userlog
cd
mv /usr/bin/userlog.x /usr/bin/userlog
chmod +x /usr/bin/userlog
cd shc-3.8.7
make
./shc -f /usr/bin/expdel
cd
mv /usr/bin/expdel.x /usr/bin/expdel
chmod +x /usr/bin/expdel
cd shc-3.8.7
make
./shc -f /usr/bin/tendang
cd
mv /usr/bin/tendang.x /usr/bin/tendang
chmod +x /usr/bin/tendang
cd shc-3.8.7
make
./shc -f /usr/bin/trial
cd
mv /usr/bin/trial.x /usr/bin/trial
chmod +x /usr/bin/trial

rm /usr/bin/tambah.x
rm /usr/bin/renew.x
rm /usr/bin/expdel.x
rm /usr/bin/pass.x
rm /usr/bin/tendang.x
rm /usr/bin/trial.x
rm /usr/bin/hapus.x
rm /usr/bin/akun.x
rm /usr/bin/userlog.x
useradd -s /bin/false -M AdityaWg
