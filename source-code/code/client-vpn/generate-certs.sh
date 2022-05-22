#!/bin/bash
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual

mkdir /tmp/acm

cd /tmp/acm

# Clone the OpenVPN easy-rsa repo
git clone https://github.com/OpenVPN/easy-rsa.git

cd easy-rsa/easyrsa3

# Initialize a new PKI environment
./easyrsa init-pki

# Build a new CA
./easyrsa build-ca nopass

# Generate server cert and key
./easyrsa build-server-full server nopass

# Generate client cert and key
./easyrsa build-client-full client1.domain.tld nopass
# Make sure to save the client certificate and the client private key because you will need them when you configure the client
# You can optionally repeat this step for each client (end user) that requires a client certificate and key

CLIENT_VPN_FILES=~/Desktop/client-vpn-files
mkdir -p  $CLIENT_VPN_FILES
cp pki/ca.crt $CLIENT_VPN_FILES/
cp pki/issued/server.crt $CLIENT_VPN_FILES/
cp pki/private/server.key $CLIENT_VPN_FILES/
cp pki/issued/client1.domain.tld.crt $CLIENT_VPN_FILES/
cp pki/private/client1.domain.tld.key $CLIENT_VPN_FILES/
cd $CLIENT_VPN_FILES

# Use the aws cli to import the certificates and keys into ACM.
aws --profile mskcourse acm import-certificate --certificate fileb://server.crt --private-key fileb://server.key --certificate-chain fileb://ca.crt

aws --profile mskcourse acm import-certificate --certificate fileb://client1.domain.tld.crt --private-key fileb://client1.domain.tld.key --certificate-chain fileb://ca.crt