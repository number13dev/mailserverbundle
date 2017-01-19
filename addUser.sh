#!/bin/bash

read -p "Bitte geben Sie den Nutzer ein: " user
read -p "Bitte geben Sie die Domain ein: " domain

echo Bitte waehle ein Passwort ...
sha=$(doveadm pw -s SSHA512)

echo $sha
shazwo=${sha:9}

echo Hallo, $user deine Domain wird lauten: $user\@$domain
echo Salted SHA512:
echo $shazwo

sql="insert into users (username, domain, password) values ('${user}', '${domain}', '${shazwo}'); SELECT ROW_COUNT()"
output=$(mysql --host="${SQL_HOSTNAME}" --user="${VMAIL_DB_USER}" --password="${SQL_PASSWORD}" --database="vmail" --execute="$sql")

echo $output
