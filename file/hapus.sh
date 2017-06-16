#!/bin/bash
#Script untuk menghapus user
#by AdityaWg
if getent passwd $1 > /dev/null 2>&1; then
        passwd -l $1
        userdel $1
        echo -e "User $1 telah dihapus."
else
        echo -e "GAGAL: User $1 tidak ada."
fi
