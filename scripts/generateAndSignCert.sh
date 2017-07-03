#!/bin/bash
if [ ! -d ca ]; then
	echo "Please run 'generateCA.sh' first."
	exit 1
fi

if [ -z "$*" ]; then
	echo "[ERR] No arguments specified"
	echo "      Usage: $0 commonName [IP address]"
	exit 1
fi

# prompt user for CA sign passphrase if not set
if [ -z "$CA_PASS"]; then
	read -s -p "Enter CA signing key passphrase: " CA_PASS
	export CA_PASS
else
	echo "[INFO] CA_PASS environment variable set, using contents as CA signing passphrase"
fi

mkdir -p ./ca/certs/$1
CONF_STRING="[req]\nreq_extensions=ext\ndistinguished_name=dn\n[dn]\n[ext]\nsubjectAltName=DNS:$1"
if [ "$#" = 2 ]
then
	CONF_STRING="$CONF_STRING,IP:$2"
fi
echo $CONF_STRING
echo "---------------------------------------"
echo -e $CONF_STRING | openssl req -new -newkey rsa:2048 -keyout ./ca/certs/${1}/${1}_key.pem -nodes -subj "/CN=$1" -config /dev/stdin -out ./ca/certs/$1/$1.csr
openssl ca -batch -passin env:CA_PASS -config ./scripts/openssl.cnf -policy policy_anything -out ./ca/certs/$1/$1.pem -infiles ./ca/certs/$1/$1.csr
openssl pkcs12 -export -inkey ./ca/certs/$1/$1_key.pem  -in ./ca/certs/$1/$1.pem -passout pass: -out ./ca/certs/$1/$1.p12
chmod 400 ./ca/certs/${1}/${1}_key.pem

