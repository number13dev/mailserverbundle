#!/bin/bash

docker run -i -d \

docker run -t -i \


docker run -t -i \
	-p 25:25 \
	-p 587:587 \
	-p 110:110 \
	-p 143:143 \
	-p 995:995 \
	-p 993:993 \
	-v /etc/letsencrypt/live/mail.tutomail.de/:/etc/letsencrypt/live/mail.tutomail.de/ \
	-v opendkim:/etc/opendkim/ \
	-v vmail:/var/vmail/ \
	-v log:/var/log/ \
	-v postfix:/etc/postfix/ptroverride/ \
	-e SQL_PASSWORD=meinsqlpassword \
	-e SPAM_PASS=spamassasinpw \
	-e SERVER_DOMAIN=tutomail.de \
	-e MAIL_SERVER_DOMAIN=mail.tutomail.de mailserver

