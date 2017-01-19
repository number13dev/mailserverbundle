#!/bin/bash

echo "mail" > /etc/hostname
echo $MAIL_HOSTNAME > /etc/mailname

mkdir -p /etc/letsencrypt/live/$MAIL_SERVER_DOMAIN/
rm -rf /config_files_sub
mkdir /config_files_sub

cp -R /config_files /config_files_sub

#DOVECOT CONFIG
sed -i "s/{{SQL_HOST}}/$SQL_PASSWORD/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{SQL_HOST}}/$SQL_HOSTNAME/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{VMAIL_DB_NAME}}/$VMAIL_DB_NAME/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" /config_files_sub/dovecot-sql.conf

cp /config_files_sub/dovecot-sql.conf
chmod 770 /etc/dovecot/dovecot-sql.conf

#POSTFIX
sed -i "s/{{MAIL_SERVER_DOMAIN}}/$MAIL_SERVER_DOMAIN/g" /config_files_sub/main.cf

for f in /config_files_sub/sql
do
  sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" $f
  sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" $f
  sed -i "s/{{SQL_HOST}}/$SQL_HOST/g" $f
  sed -i "s/{{VMAIL_DB_NAME}}/$VMAIL_DB_NAME/g" $f
done

cp /config_files_sub/main.cf /etc/postfix/main.cf
cp /config_files_sub/master.cf /etc/postfix/master.cf
cp -R /config_files_sub/sql/ /etc/postfix/sql/

if [ -f "/etc/opendkim/keytable" ]
then
	echo "opendkim key exists"
else
	touch /etc/opendkim/keytable
	opendkim-genkey --selector=key1 --bits=2048 --directory=/etc/opendkim/keys
	chown opendkim /etc/opendkim/keys/key1.private
    echo "default    %:key1:/etc/opendkim/keys/key1.private" > /etc/opendkim/keytable
fi

#SPAMASSASSIN
sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" /config_files_sub/local.cf
sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" /config_files_sub/local.cf
sed -i "s/{{SQL_HOST}}/$SQL_HOST/g" /config_files_sub/local.cf

cp /config_files_sub/local.cf /etc/mail/spamassassin/local.cf

#AMAVIS CONTENT FILTER
sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" /config_files_sub/50-user
sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" /config_files_sub/50-user
sed -i "s/{{SQL_HOST}}/$SQL_HOST/g" /config_files_sub/50-user
sed -i "s/{{VMAIL_DB_NAME}}/$VMAIL_DB_NAME/g" /etc/amavis/conf.d/50-user

cp /config_files_sub/50-user /etc/amavis/conf.d/50-user

echo "NEW ALIASES"
newaliases

echo "STARTING"
service dovecot start
systemctl start amavisd-new
systemctl start amavisd-milter
service opendkim start
service postfix start

service dovecot reload
service postfix reload

/bin/bash
#tail -f /dev/null
