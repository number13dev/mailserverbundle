#!/bin/bash


export LETSENCRYPT_PATH=/etc/letsencrypt/live/
export MAIL_SERVER_DOMAIN=mail.mysystems.tld

export SQL_PASSWORD=FILL_IN_PASSWORD
export SPAM_PASS=FILL_IN_PASSWORD


##HERE
export VMAILHOME=/var/vmail/
export MAILHOME=${VMAILHOME}/mailboxes/

#DOVEVOT
DOLLAR='$' envsubst < "dovecot_.conf" > "dovecot.conf"
DOLLAR='$' envsubst < "dovecot-sql_.conf" > "dovecot-sql.conf"

#POSTFIX
DOLLAR='$' envsubst < "main_.conf" > "main.conf"


DOLLAR='$' envsubst < "mysql-aliases_.cf" > "mysql-aliases.cf"
DOLLAR='$' envsubst < "mysql-domains_.cf" > "mysql-domains.cf"
DOLLAR='$' envsubst < "mysql-maps_.cf" > "mysql-maps.cf"
DOLLAR='$' envsubst < "sender-login-maps_.cf" > "sender-login-maps.cf"
DOLLAR='$' envsubst < "tls-policy_.cf" > "tls-policy.cf"


#AMAVIS
DOLLAR='$' envsubst < "50-user_" > "50-user"

#SPAMASSASSIN
DOLLAR='$' envsubst < "local_.cf" > "local.cf"
