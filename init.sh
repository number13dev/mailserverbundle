#!/bin/bash
echo " RUNNING INIT"

mkdir -p /etc/myssl
mkdir -p /var/vmail
mkdir -p /etc/vmail/mailboxes/
mkdir -p /etc/vmail/sieve/global
mkdir -p /etc/postfix/sql/
mkdir -p /etc/postfix/ptroverride/
mkdir -p /etc/opendkim/keys


#copy static config files
cp /config_files/amavisd-milter.service /etc/systemd/system/amavisd-milter.service
cp /care_scripts/spampipe.sh /etc/vmail/spampipe.sh
cp /config_files/spam-global.sieve /etc/vmail/sieve/global/spam-global.sieve
cp /config_files/opendkim.conf /etc/opendkim.conf


#create some files
#ptr overrride
touch /etc/postfix/ptroverride/without_ptr
touch /etc/postfix/ptroverride/postscreen_access

adduser --disabled-login --disabled-password --gecos "" --home /etc/vmail/ vmail

#chown/chmod/chgrp
chown -R vmail:vmail /etc/vmail/
chgrp -R vmail /etc/vmail/
chmod -R 770 /etc/vmail/
chmod -R 660 /etc/postfix/sql
chown vmail:vmail /etc/vmail/spampipe.sh
chmod +u+x /etc/vmail/spampipe.sh
chmod +u+x /care_scripts/sa-care.sh

#Install CRON
crontab -l > mycron
echo "@daily FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem" >> mycron
echo "@daily /care_scripts/sa-care.sh" >> mycron
crontab mycron
rm mycron

#Execute one time
FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem
/care_scripts/sa-care.sh


postmap /etc/postfix/ptroverride/without_ptr
service postfix reload
newaliases

#OPENDKIM
usermod -aG opendkim postfix

#AMAVISD-MILTER COMPILIEREN
#wget 'https://github.com/ThomasLeister/amavisd-milter/archive/master.zip' -O amavisd-milter.zip
#unzip amavisd-milter.zip
#cd amavisd-milter-master
#./configure
#make
#make install
#make clean
#cd ..
#rm -r amavisd-milter-master
#rm amavisd-milter.zip

systemctl enable amavisd-milter

#SPAMASSASSIN
setfacl -m o:--- /etc/mail/spamassassin/local.cf
setfacl -m u:vmail:r /etc/mail/spamassassin/local.cf
setfacl -m u:amavis:r /etc/mail/spamassassin/local.cf