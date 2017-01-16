#!/bin/bash
./config_files.sh

FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem

#DOVECOT CONFIG
cp ${SUBSTITUED_CF_PATH}dovecot.conf /etc/dovecot/dovecot.conf
cp ${SUBSTITUED_CF_PATH}dovecot-sql.conf /etc/dovecot/dovecot-sql.conf
chmod 770 /etc/dovecot/dovecot-sql.conf

#POSTFIX
cp ${SUBSTITUED_CF_PATH}main.cf /etc/postfix/main.cf
cp ${SUBSTITUED_CF_PATH}master.cf /etc/postfix/master.cf
cp -R ${SUBSTITUED_CF_PATH}/sql/ /etc/postfix/sql/

#OPENDKIM
cp ${CF_PATH}opendkim.conf /etc/opendkim.conf

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
cp ${SUBSTITUED_CF_PATH}local.cf /etc/mail/spamassassin/local.cf

#AMAVIS CONTENT FILTER
cp ${SUBSTITUED_CF_PATH}50-user /etc/amavis/conf.d/50-user

echo "RELOADING SERVICES"
service dovecot reload
service postfix reload
newaliases

echo "STARTING"
service dovecot start
systemctl start amavisd-new
systemctl start amavisd-milter
service opendkim start
service postfix start
