#!/bin/bash
##HERE
echo "RUNNING CONFIG FILES"

SQL_PATH=/mailserver/subs_files/sql/
mkdir /mailserver/subs_files/
mkdir ${SQL_PATH}
echo "- SUB - CONFIG -"

#DOVEVOT
DOLLAR='$' envsubst < "/mailserver/config_files/dovecot.conf" > "/mailserver/subs_files/dovecot.conf"
DOLLAR='$' envsubst < "/mailserver/config_files/dovecot-sql_conf" > "/mailserver/subs_files/dovecot-sql.conf"

#POSTFIX
DOLLAR='$' envsubst < "/mailserver/config_files/main.cf" > "/mailserver/subs_files/main.cf"
DOLLAR='$' envsubst < "/mailserver/config_files/master_.cf" > "/mailserver/subs_files/master.cf"

#POSTFIX-SQL-FILES
DOLLAR='$' envsubst < "/mailserver/config_files/sql/aliases_.cf" > "${SQL_PATH}aliases.cf"
DOLLAR='$' envsubst < "/mailserver/config_files/sql/domains.cf" > "${SQL_PATH}domains.cf"
DOLLAR='$' envsubst < "/mailserver/config_files/sql/maps.cf" > "${SQL_PATH}mysql-maps.cf"
DOLLAR='$' envsubst < "/mailserver/config_files/sql/sender-login-maps.cf" > "${SQL_PATH}sender-login-maps.cf"
DOLLAR='$' envsubst < "/mailserver/config_files/sql/tls-policy.cf" > "${SQL_PATH}tls-policy.cf"
DOLLAR='$' envsubst < "/mailserver/config_files/sql/recipient-access.cf" > "${SQL_PATH}recipient-access.cf"


#AMAVIS
DOLLAR='$' envsubst < "/mailserver/config_files/50-user" > "/mailserver/subs_files/50-user"

#SPAMASSASSIN
DOLLAR='$' envsubst < "/mailserver/config_files/local.cf" > "/mailserver/subs_files/local.cf"

#INIT_DB SKRIPT
DOLLAR='$' envsubst < "/mailserver/init_db_.sh" > "/mailserver/init_db.sh"

echo "SUB DONE"
