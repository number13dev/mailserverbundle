# MAIL SERVER WITH DOCKER
## DOVECOT - POSTFIX - SPAMASSASSIN

**Don't run this in production! This container is in an early stage of development!**

You'll need the Postfixadmin Container to create the vmail Tables.


```
docker run -t -i \
	-p 25:25 \
	-p 587:587 \
	-p 110:110 \
	-p 143:143 \
	-p 995:995 \
	-p 993:993 \
	-v /etc/letsencrypt:/etc/letsencrypt \
	-v ~/opendkim:/etc/opendkim \
	-v ~/vmail:/var/vmail \
	-v ~/maillog:/var/log \
	-v ~/postfix/ptr:/etc/postfix/ptroverride \
	-e SQL_PASSWORD=my-secret-pw \
	-e SQL_HOSTNAME=meinesql \
	-e VMAIL_DB_NAME=vmail \
	-e VMAIL_DB_USER=root \
	-e VMAIL_DB_PW=my-other-secret-pw \
	-e SPAM_PW=spamasspw \
	-e MAIL_SERVER_DOMAIN=mail.tutomail.de
	mailserver
```


