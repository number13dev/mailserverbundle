#!/bin/bash
OPENDKIM_FOLDER=opendkim/
MAIL_HOME_FOLDER=vmail/


mkdir ${OPENDKIM_FOLDER}
touch ${OPENDKIM_FOLDER}/TODO_DNS_RECORDS

docker run -d -v ${OPENDKIM_FOLDER}:/etc/opendkim/ 
