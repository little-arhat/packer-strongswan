#!/bin/sh
set -e

sudo apt-get update
sudo apt-get install -y strongswan rsyslog git-core strongswan-ike strongswan-plugin-af-alg \
     strongswan-plugin-agent  \
     strongswan-plugin-eap-gtc strongswan-plugin-eap-md5 strongswan-plugin-eap-mschapv2 \
     strongswan-plugin-fips-prf strongswan-plugin-openssl strongswan-plugin-pubkey \
     strongswan-plugin-unbound strongswan-plugin-xauth-eap strongswan-plugin-xauth-generic \
     strongswan-starter strongswan-plugin-unity

sudo /bin/su -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.all.rp_filter=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.default.rp_filter=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.eth0.rp_filter=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.lo.rp_filter=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.all.send_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.default.send_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.eth0.send_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.lo.send_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.all.accept_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.default.accept_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.eth0.accept_redirects=0' >> /etc/sysctl.conf"
sudo /bin/su -c "echo 'net.ipv4.conf.lo.accept_redirects=0' >> /etc/sysctl.conf"

sudo sysctl -p

sudo mv /tmp/rc.local /etc/rc.local

sudo iptables --table nat --append POSTROUTING --jump MASQUERADE

sudo mv /tmp/charon.conf /etc/strongswan.d/charon.conf

sudo chmod +x /home/ubuntu/setup-ipsec.sh
sudo chmod +x /home/ubuntu/add-ipsec-user.sh

sudo ipsec restart
