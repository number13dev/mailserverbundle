#!/bin/bash

read -p "Bitte gebe Weiterleitungs E-Mail ein: " source
read -p "Bitte gebe Ziel E-Mail ein: " destination


sql="insert into aliases (source, destination) values ('${source}', '${destination}'); SELECT ROW_COUNT()"
output=$(mysql --user="vmail" --password="SQL_PASSWORD" --database="vmail" --execute="$sql")

echo $output