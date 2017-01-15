#!/bin/bash

DOMAINS=(domain1.tld domain2.tld domain3.tld)

echo "mail" > /etc/hostname
echo "mail.pccg.de" > /etc/mailname
mkdir /etc/myssl

crontab -l > mycron
echo "@daily FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem" >> mycron
crontab mycron
rm mycron

FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem

mkdir /var/vmail

adduser --disabled-login --disabled-password --home ${VMAILHOME} vmail

mkdir ${MAILHOME}
mkdir -p ${VMAILHOME}/sieve/global

chown -R vmail ${VMAILHOME}
chgrp -R vmail ${VMAILHOME}
chmod -R 770 ${VMAILHOME}


#DOVECOT CONFIG
cp dovecot.conf /etc/dovecot/dovecot.conf
cp dovecot-sql.conf /etc/dovecot/dovecot-sql.conf
chmod 770 /etc/dovecot/dovecot-sql.conf

cp spampipe.sh ${VMAILHOME}spampipe.sh

chown vmail:vmail ${VMAILHOME}spampipe.sh
chmod u+x ${VMAILHOME}spampipe.sh

cp spam-global.sieve ${VMAILHOME}sieve/global/spam-global.sieve

#POSTFIX

cp main.cf /etc/postfix/main.cf
cp -R sql/sql /etc/postfix/sql
chmod -R 660 /etc/postfix/sql

newaliases

#OPENDKIM

> /etc/opendkim.conf

cp opendkim.conf /etc/opendkim.conf

mkdir /etc/opendkim
mkdir /etc/opendkim/keys

opendkim-genkey --selector=key1 --bits=2048 --directory=/etc/opendkim/keys

touch /etc/opendkim/keytable

echo "default    %:key1:/etc/opendkim/keys/key1.private" > keytable

touch /etc/opendkim/dns_records

for i in "${DOMAINS[@]}"
	do
		echo "key1._domainkey${i}. 3600 IN TXT \"v=DKIM1; k=rsa; \" PASTE_DKIM_KEY" > /etc/opendkim/dns_records
done

touch /etc/opendkim/signingtable

echo "* default" > /etc/opendkim/signingtable

chown opendkim /etc/opendkim/keys/key1.private
usermod -aG opendkim postfix

#AMAVIS CONTENT FILTER

cp 50-user /etc/amavis/conf.d/50-user



