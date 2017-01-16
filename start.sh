#!/bin/bash
./config_files.sh

mkdir -p /etc/letsencrypt/live/${MAIL_SERVER_DOMAIN}/
chown -R vmail:root mail.tutomail.de/

#DOVECOT CONFIG
cp /mailserver/subs_files/dovecot.conf /etc/dovecot/dovecot.conf
cp /mailserver/subs_files/dovecot-sql.conf /etc/dovecot/dovecot-sql.conf
chmod 770 /etc/dovecot/dovecot-sql.conf

#POSTFIX
cp /mailserver/subs_files/main.cf /etc/postfix/main.cf
cp /mailserver/subs_files/master.cf /etc/postfix/master.cf
cp -R /mailserver/subs_files/sql/ /etc/postfix/sql/

#OPENDKIM
cp /mailserver/config_files/opendkim.conf /etc/opendkim.conf

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

#SPAMASSASSIN
cp /mailserver/subs_files/local.cf /etc/mail/spamassassin/local.cf

#AMAVIS CONTENT FILTER
cp /mailserver/subs_files/50-user /etc/amavis/conf.d/50-user

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
