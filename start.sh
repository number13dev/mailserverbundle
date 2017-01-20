#!/bin/bash

hostname mail
echo $MAIL_HOSTNAME > /etc/mailname

mkdir -p /etc/letsencrypt/live/$MAIL_SERVER_DOMAIN/

echo "creating fresh config files"
rm -rf /config_files_sub
cp -r /config_files /config_files_sub

#DOVECOT CONFIG

#DOVECOT SQL
sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{SQL_HOSTNAME}}/$SQL_HOSTNAME/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{VMAIL_DB_NAME}}/$VMAIL_DB_NAME/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" /config_files_sub/dovecot-sql.conf
sed -i "s/{{MAIL_SERVER_DOMAIN}}/$MAIL_SERVER_DOMAIN/g" /config_files_sub/dovecot-sql.conf

#DOVECOT MAIN
sed -i "s/{{MAIL_SERVER_DOMAIN}}/$MAIL_SERVER_DOMAIN/g" /config_files_sub/dovecot.conf
cp /config_files_sub/dovecot-sql.conf /etc/dovecot/dovecot-sql.conf
cp /config_files_sub/dovecot.conf /etc/dovecot/dovecot.conf
chmod 0600 /etc/dovecot/dovecot-sql.conf

#AMAVIS
sed -i "s/{{MAIL_SERVER_DOMAIN}}/$MAIL_SERVER_DOMAIN/g" /config_files_sub/05-node_id
cp /config_files_sub/05-node_id /etc/amavis/conf.d/05-node_id

#POSTFIX
sed -i "s/{{MAIL_SERVER_DOMAIN}}/$MAIL_SERVER_DOMAIN/g" /config_files_sub/main.cf

for f in /config_files_sub/sql/*
do
  sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" $f
  sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" $f
  sed -i "s/{{SQL_HOST}}/$SQL_HOSTNAME/g" $f
  sed -i "s/{{VMAIL_DB_NAME}}/$VMAIL_DB_NAME/g" $f
done

cp /config_files_sub/main.cf /etc/postfix/main.cf
cp /config_files_sub/master.cf /etc/postfix/master.cf
rm -rf /etc/postfix/sql
cp -R /config_files_sub/sql/ /etc/postfix/sql/

#opendkim
touch /etc/opendkim/signingtable
echo "* default" > /etc/opendkim/signingtable

if [ -f "/etc/opendkim/keytable" ]
then
	echo "opendkim key exists"
else
    echo "keytable does not exists - creating"
	touch /etc/opendkim/keytable
	mkdir -p /etc/opendkim/keys
	opendkim-genkey -s mail --bits=2048 --directory=/etc/opendkim/keys
	chown opendkim:opendkim /etc/opendkim/keys/mail.private
    echo "default    %:mail:/etc/opendkim/keys/mail.private" > /etc/opendkim/keytable
fi
chown -R opendkim:opendkim /etc/opendkim
chmod 0600 /etc/opendkim/keys/mail.private

#SPAMASSASSIN
sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" /config_files_sub/local.cf
sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" /config_files_sub/local.cf
sed -i "s/{{SQL_HOST}}/$SQL_HOST/g" /config_files_sub/local.cf

cp /config_files_sub/local.cf /etc/mail/spamassassin/local.cf

#AMAVIS CONTENT FILTER
sed -i "s/{{VMAIL_DB_USER}}/$VMAIL_DB_USER/g" /config_files_sub/50-user
sed -i "s/{{SQL_PASSWORD}}/$SQL_PASSWORD/g" /config_files_sub/50-user
sed -i "s/{{SQL_HOST}}/$SQL_HOST/g" /config_files_sub/50-user
sed -i "s/{{VMAIL_DB_NAME}}/$VMAIL_DB_NAME/g" /config_files_sub/50-user

cp /config_files_sub/50-user /etc/amavis/conf.d/50-user
chmod 770 /etc/amavis/conf.d/50-user

chown -R vmail /var/vmail
chgrp -R vmail /var/vmail
chmod -R 770 /var/vmail

echo "NEW ALIASES"
newaliases

#wait for database to start up
echo "wait for database"
while !(mysqladmin -h $SQL_HOSTNAME -u $VMAIL_DB_USER -p$SQL_PASSWORD ping)
do
    sleep 1
done
echo "database on"

echo "init database"
./init_db.sh


echo "STARTING"

/etc/init.d/rsyslog start
systemctl enable amavisd-milter

/etc/init.d/amavis start
/etc/init.d/amavisd-milter start

/etc/init.d/opendkim start
service dovecot start
/etc/init.d/postfix start

#create postmaster user
sql="insert ignore into domains (domain) values ('${DOMAIN:-MAIL_SERVER_DOMAIN}'); SELECT ROW_COUNT()"
output=$(mysql --host="${SQL_HOSTNAME}" --user="${VMAIL_DB_USER}" --password="${SQL_PASSWORD}" --database="${VMAIL_DB_NAME}" --execute="$sql")
echo $output

sha=$(doveadm pw -s SSHA512 -p ${POSTMASTER_PW})
echo $sha
shazwo=${sha:9}
sql="insert ignore into users (username, domain, password) values ('postmaster', '${DOMAIN:-MAIL_SERVER_DOMAIN}', '${shazwo}'); SELECT ROW_COUNT()"
output=$(mysql --host="${SQL_HOSTNAME}" --user="${VMAIL_DB_USER}" --password="${SQL_PASSWORD}" --database="${VMAIL_DB_NAME}" --execute="$sql")
echo $output

mail -a /opt/backup.sql -s "Your DKIM Public Key" postmaster@${DOMAIN:-$MAIL_SERVER_DOMAIN} < /dev/null

#/bin/bash
tail -f /var/log/syslog
tail -f /dev/null
