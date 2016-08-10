#!/usr/bin/env bash

#checks a server for supported TLS ciphers

SERV=$1
PORT=$2
ADDR=$SERV:$PORT
supported=${@}
ciphers=`openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g'`

echo "[+] Getting ciphers from: `openssl version`"

for cipher in ${ciphers[@]} 
do
    echo "[+] Testing $cipher... "
    result=`echo -n | openssl s_client -cipher "$cipher" -connect $ADDR 2>&1`
    if [[ "$result" =~ ":error:" ]] ; then
        error=`echo -n $result | cut -d':' -f6`
        echo "[-] NOPE ($error)"
    else
        if [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher     :" ]] ; then
            echo "[+] YES"
            supported+=(${cipher})
        else
            echo "[!] I DON'T KNOW WHAT THIS IS"
            echo $result
        fi
    fi
done
echo "[+] Supported cipher list: ${supported[@]}"
