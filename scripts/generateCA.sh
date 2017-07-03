#!/bin/bash
mkdir -p ca/private
mkdir -p ca/certs
touch ca/index.txt

openssl req -new -keyout ./ca/private/ca_priv.pem -out ./ca/careq.pem -config ./scripts/openssl.cnf

openssl ca -config scripts/openssl.cnf -create_serial -out ./ca/ca.pem -days 3650 -batch -keyfile ./ca/private/ca_priv.pem -selfsign -extensions v3_ca -infiles ./ca/careq.pem

chmod 400 ./ca/private/ca_priv.pem
echo "Generated CA in 'ca/ca.pem' with its private key in './ca/private/ca_priv.pem'"
