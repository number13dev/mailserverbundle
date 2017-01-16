#!/bin/bash
OPENDKIM_FOLDER=opendkim/
MAIL_HOME_FOLDER=vmail/
LOG_FOLDER=log/
PTR_OVERRIDE=postfix/


#substitute config files
chmod +x config_files.sh
./config_files.sh


mkdir ${OPENDKIM_FOLDER}
mkdir ${MAIL_HOME_FOLDER}
mkdir ${LOG_FOLDER}
mkdir ${PTR_OVERRIDE}

docker run -i -d \
	-p 25:25 \
	-p 587:587 \
	-p 110:110 \
	-p 143:143 \
	-p 995:995 \
	-p 993:993 \
	-v ${OPENDKIM_FOLDER}:/etc/opendkim/ \
	-v ${MAIL_HOME_FOLDER}:/var/vmail/ \ 
	-v ${LOG_FOLDER}:/var/log/ \
	-v ${PTR_OVERRIDE}:/etc/postfix/ptroverride/ \

