#!/bin/bash
echo "################ RUNNING INIT ################"
SQL_PATH=${SUBSTITUED_CF_PATH}sql/
DOMAINS=(domain1.tld domain2.tld domain3.tld)

echo "BEGIN"

echo "mail" > /etc/hostname
echo $MAIL_SERVER_DOMAIN > /etc/mailname
mkdir -p /etc/myssl

crontab -l > mycron
echo "@daily FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem" >> mycron
crontab mycron
rm mycron

FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem

mkdir /etc/myssl
mkdir /var/vmail
adduser --disabled-login --disabled-password --gecos "" --home /etc/vmail/ vmail

mkdir -p /etc/vmail/mailboxes/
mkdir -p /etc/vmail/sieve/global

chown -R vmail:vmail /etc/vmail/
chgrp -R vmail /etc/vmail/
chmod -R 770 /etc/vmail/

cp /mailserver/care_scripts/spampipe.sh /etc/vmail/spampipe.sh

chown vmail:vmail /etc/vmail/spampipe.sh
chmod u+x /etc/vmail/spampipe.sh

cp /mailserver/config_files/spam-global.sieve /etc/vmail/sieve/global/spam-global.sieve

mkdir -p /etc/postfix/sql/
chmod -R 660 /etc/postfix/sql

	#ptr overrride
mkdir /etc/postfix/ptroverride/
touch /etc/postfix/ptroverride/without_ptr
touch /etc/postfix/ptroverride/postscreen_access

postmap /etc/postfix/ptroverride/without_ptr
service postfix reload
newaliases

#OPENDKIM
usermod -aG opendkim postfix
mkdir /etc/opendkim
mkdir /etc/opendkim/keys

#AMAVISD-MILTER COMPILIEREN
wget 'https://github.com/ThomasLeister/amavisd-milter/archive/master.zip' -O amavisd-milter.zip
unzip amavisd-milter.zip
cd amavisd-milter-master
./configure
make
make install
make clean
cd ..

rm -r amavisd-milter-master
rm amavisd-milter.zip

cp /mailserver/config_files/amavisd-milter.service /etc/systemd/system/amavisd-milter.service

systemctl enable amavisd-milter

#SPAMASSASSIN

setfacl -m o:--- /etc/mail/spamassassin/local.cf
setfacl -m u:vmail:r /etc/mail/spamassassin/local.cf
setfacl -m u:amavis:r /etc/mail/spamassassin/local.cf

#WARTUNGSSKRIPT

cp /mailserver/care_scripts/sa-care.sh sa-care.sh
chmod +u+x sa-care.sh

crontab -l > mycron
echo "@daily /root/sa-care.sh" >> mycron
crontab mycron
rm mycron

./sa-care.sh


