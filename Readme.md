
# General

Image for configuring VPN server.

This image comes with StrongSwan and all plugins needed installed.
Necessary tcp/ip options are also made.

source id: ami-678b260c -- Ubuntu 14.04.3 LTS (Trusty Tahr)

last built image: ami-b9a108d2

# Instance setup

Instance for VPN server should be created in public subnet of target VPC and should either have public ip
or elastic IP attached. Source/destination checks should be disabled for this instance and Security group
should allow UDP connections on 500 and 4500 ports.

For initial setup, SSH from outside world should be allowed, as users should be created via SSH.
After first user created, though, SSH can be allowed only from VPC.

# Usage

Image provides two scrpits to facilitate IPSec setup.

`setup-ipsec.sh` generates configuration suitable to give access to provided subnet
One can run it like `sudo /home/ubuntu/setup-ipsec.sh 172.12.0.0/20 172.12.32.0/28`, where first argument is
target subnet, and second is subnet to give IP addresses to clients from.

This script can be called via Terraform `remote-exec` provisioner or AWS `cloud-init` feature.

Scrpit creates VPN connection, authentificated via Pre-Shared Key. Key can be seen in `/etc/ipsec.secrets`.
This key should be used on client endpoints. VPN tunnel is only used for connections made to target
subnet. All other destinations will be unaffected by VPN connection.

Clients are authinetificated via PSK and XAUTH, so users should be added to `/etc/ipsec.secret`.

To make user creation easier second script can be used. `sudo /home/ubuntu/add-ipsec-user.sh <USERNAME>` can be
called to create user <USERNAME>. Script will request password and will generate it by itself, if empty
password was supplied.

# Caveats

ami-b9a108d2 is built with wrong `rc.local` and will not start `strongswan` on startup.
