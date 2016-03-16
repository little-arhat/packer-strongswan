#!/bin/bash
set -e

generatePass() {
    openssl rand -base64 $1 2>1 | tr -d "\n"
}

if [ $# -eq 0 ]
then
    echo "Usage : ./add-user username"
    exit 1
fi


if [ -z "$1" ]
then
    echo "User can not be and empty string"
    exit 1
fi

USER=$1

read -s -p "Enter Password: " UPASS

if [ -z "$UPASS" ]
then
    echo "Can't use empty password, will generate random..."
    UPASS=`generatePass 16`
fi

cat <<EOF >> /etc/ipsec.secrets

$USER : XAUTH "$UPASS"
$USER : EAP "$UPASS"
EOF

echo "User '$USER' was added with password '$UPASS'"
echo "Running 'ipsec rereadsecrets'"
ipsec rereadsecrets
echo "All done!"
