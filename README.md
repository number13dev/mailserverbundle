# MAIL SERVER WITH DOCKER
## DOVECOT - POSTFIX - SPAMASSASSIN - with MYSQL
###### inspired by: [Thomas Leistners Mailserver-Setup](https://thomas-leister.de/mailserver-unter-ubuntu-16.04/)


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
	-v /var/log:/var/log \
	-v ~/postfix/ptr:/etc/postfix/ptroverride \
	-e SQL_PASSWORD=meinsqlpassword \
	-e SQL_HOSTNAME=mysql \
	-e MAIL_SERVER_DOMAIN=mail.tutomail.de \
	mailserver
```