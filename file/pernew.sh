#!/bin/bash
if [ $(id -u) -eq 0 ]; then
        if ! [[ "$2" =~ ^[0-9]+$ ]] ;
        then exec >&2; echo "ERROR! Ngelindur ya bro? Hanya bisa diisi angka tuh!!"; exit 1
fi
        egrep "^${1}:" /etc/passwd >/dev/null
        if [ "$1" = "" ]
        then
                echo "ERROR! Akun $1 tidak ada di server. Cek lagi!"
                exit 1
        else
                exp="$(chage -l $1 | grep "Account expires" | awk -F": " '{print $2}')"
                usermod -U -e `date -d "$2 days $exp" +"%Y-%m-%d"` $1 &> /dev/null
                [ $? -eq 0 ] && echo "SUKSES! TGL EXPIRE LAMA: `date -d "$exp" +"%d-%b-%Y"` ========> MENJADI: `date -d "$2 days $exp" +"%d-%b-%Y"`" || echo "Error! Mungkin Anda kurang ganteng :D"
                echo "---------------------------------------------------------------------"
        fi
else
        echo "Hanya root yang bisa menjalankan perintah ini"
        exit 2
fi
