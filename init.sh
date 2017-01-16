#!/bin/bash

DOMAINS=(domain1.tld domain2.tld domain3.tld)

echo "mail" > /etc/hostname
echo $MAIL_SERVER_DOMAIN > /etc/mailname
mkdir /etc/myssl

crontab -l > mycron
echo "@daily FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem" >> mycron
crontab mycron
rm mycron

mkdir /etc/myssl

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

cp amavisd-milter.service /etc/systemd/system/amavisd-milter.service

systemctl enable amavisd-milter

#SPAMASSASSIN

cp local.cf /etc/mail/spamassassin/local.cf

setfacl -m o:--- /etc/mail/spamassassin/local.cf
setfacl -m u:vmail:r /etc/mail/spamassassin/local.cf
setfacl -m u:amavis:r /etc/mail/spamassassin/local.cf

#WARTUNGSSKRIPT

cp sa-care.sh /root/sa-care.sh
chmod +u+x sa-care.sh

crontab -l > mycron
echo "@daily /root/sa-care.sh" >> mycron
crontab mycron
rm mycron

/root/sa-care.sh

#razor registrieren
sudo -i -u amavis
razor-admin -create
razor-admin -register
pyzor discover

exit


