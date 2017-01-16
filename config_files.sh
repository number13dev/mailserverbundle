#!/bin/bash
##HERE
echo "RUNNING CONFIG FILES"

export VMAILHOME=/var/vmail/

CF_PATH=config_files/
export SUBSTITUED_CF_PATH=subs_files/
export CARE_SCRIPT_PATH=care_scripts/
SQL_PATH=${SUBSTITUED_CF_PATH}/sql/

mkdir ${SUBSTITUED_CF_PATH}
mkdir ${SQL_PATH}

#DOVEVOT
DOLLAR='$' envsubst < "${CF_PATH}dovecot_.conf" > "${SUBSTITUED_CF_PATH}dovecot.conf"
DOLLAR='$' envsubst < "${CF_PATH}dovecot-sql_.conf" > "${SUBSTITUED_CF_PATH}dovecot-sql.conf"

#POSTFIX
DOLLAR='$' envsubst < "${CF_PATH}main_.cf" > "${SUBSTITUED_CF_PATH}main.conf"
DOLLAR='$' envsubst < "${CF_PATH}master_.cf" > "${SUBSTITUED_CF_PATH}main.conf"

#POSTFIX-SQL-FILES
DOLLAR='$' envsubst < "${CF_PATH}sql/aliases_.cf" > "${SQL_PATH}aliases.cf"
DOLLAR='$' envsubst < "${CF_PATH}sql/domains_.cf" > "${SQL_PATH}domains.cf"
DOLLAR='$' envsubst < "${CF_PATH}sql/maps_.cf" > "${SQL_PATH}mysql-maps.cf"
DOLLAR='$' envsubst < "${CF_PATH}sql/sender-login-maps_.cf" > "${SQL_PATH}sender-login-maps.cf"
DOLLAR='$' envsubst < "${CF_PATH}sql/tls-policy_.cf" > "${SQL_PATH}tls-policy.cf"
DOLLAR='$' envsubst < "${CF_PATH}sql/recipient-access_.cf" > "${SQL_PATH}recipient-access.cf"


#AMAVIS
DOLLAR='$' envsubst < "${CF_PATH}50-user_" > "${SUBSTITUED_CF_PATH}50-user"

#SPAMASSASSIN
DOLLAR='$' envsubst < "${CF_PATH}local_.cf" > "${SUBSTITUED_CF_PATH}local.cf"
