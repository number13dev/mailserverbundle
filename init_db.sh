#!/bin/bash

echo "Database Setup"
mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME -se "CREATE DATABASE IF NOT EXISTS vmail;"
mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME -se "CREATE TABLE IF NOT EXISTS vmail.domains (domain VARCHAR(128) NOT NULL, UNIQUE INDEX domain (domain ASC));"
mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME -se "CREATE TABLE IF NOT EXISTS vmail.users (id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, username VARCHAR(128) NOT NULL, domain VARCHAR(128) NOT NULL, password VARCHAR(128) NOT NULL, mailbox_limit INT(11) NOT NULL DEFAULT '1000', PRIMARY KEY (username, domain), UNIQUE INDEX id (id ASC));"
mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME -se "CREATE TABLE IF NOT EXISTS vmail.aliases (id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, source VARCHAR(128) NOT NULL, destination VARCHAR(128) NOT NULL, user_id INT(11) NULL DEFAULT NULL, PRIMARY KEY (source, destination), UNIQUE INDEX id (id ASC));"
mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME -se "CREATE TABLE IF NOT EXISTS vmail.tlspolicies (id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT, domain VARCHAR(255) NOT NULL, policy ENUM('none', 'may', 'encrypt', 'dane', 'dane-only', 'fingerprint', 'verify', 'secure') NOT NULL, params VARCHAR(255) NULL DEFAULT NULL, PRIMARY KEY (id), UNIQUE INDEX domain (domain ASC));"


echo "Spamassassin"
mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME -se "CREATE DATABASE IF NOT EXISTS spamassassin;"

cat /usr/share/doc/spamassassin/sql/bayes_mysql.sql | mysql -u $VMAIL_DB_USER -p$SQL_PASSWORD -h $SQL_HOSTNAME --database="spamassassin"

