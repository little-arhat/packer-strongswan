#!/bin/bash
set -e

generatePass() {
    openssl rand -base64 $1 2>1 | tr -d "\n"
}

SUBNET=$1
POOL=$2

PSK=`generatePass 64`

cat > /etc/ipsec.conf <<EOF
config setup
        uniqueids=never
        charondebug="cfg 2, dmn 2, ike 2, net 2"

conn %default
        keyexchange=ikev2
        ike=aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4096,aes128-sha256-modp1536,aes256-sha3$
        esp=aes128gcm16-ecp256,aes256gcm16-ecp384,aes128-sha256-ecp256,aes256-sha384-ecp384,aes128-sha256-modp2048,aes256-sha384-modp4096,aes256-sha256-modp4$
        dpdaction=clear
        dpddelay=300s
        rekey=no
        left=%any
        leftsubnet=$SUBNET
        leftauth=psk
        right=%any
        rightsourceip=$POOL

conn IPSec-IKEv2
        keyexchange=ikev2
        auto=add

conn IPSec-IKEv2-EAP
        also="IPSec-IKEv2"
        rightauth=eap-mschapv2
        rightsendcert=never
        eap_identity=%any

conn CiscoIPSec
        keyexchange=ikev1
        rightauth=psk
        rightauth2=xauth
        auto=add
EOF

cat > /etc/ipsec.secrets <<EOF
 : PSK "$PSK"
EOF

cat > /etc/strongswan.d/charon/attr.conf <<EOF
# Section to specify arbitrary attributes that are assigned to a peer via
# configuration payload (CP).
attr {
    # Whether to load the plugin. Can also be an integer to increase the
    # priority of this plugin.
    load = yes
    split-include=$SUBNET
    split-exclude=0.0.0.0/0
}
EOF

# for some reason script ran by packer is not always update everything
sysctl -p

iptables --table nat --append POSTROUTING --jump MASQUERADE

ipsec restart
