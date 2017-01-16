#!/bin/bash
OPENDKIM_FOLDER=opendkim/
MAIL_HOME_FOLDER=vmail/
LOG_FOLDER=log/


mkdir ${OPENDKIM_FOLDER}
mkdir ${MAIL_HOME_FOLDER}
mkdir ${LOG_FOLDER}

docker run -d -v ${OPENDKIM_FOLDER}:/etc/opendkim/ -v ${MAIL_HOME_FOLDER}:/var/vmail/ -v ${LOG_FOLDER}:/var/log/ 
