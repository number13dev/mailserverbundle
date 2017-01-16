FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

ENV LETSENCRYPT_PATH=/etc/letsencrypt/live/
ENV MAIL_SERVER_DOMAIN=mail.mysystems.tld

ENV SQL_PASSWORD=SQLPASSWORD

ENV SPAM_PASS=SPAMPASSWORD

RUN apt-get update && apt-get install -y \
	cron \
	openssl \
	git \
	dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-sieve dovecot-managesieved dovecot-antispam \
	postfix postfix-mysql \
	opendkim opendkim-tools \
	amavisd-new libdbi-perl libdbd-mysql-perl \
	gcc libmilter-dev make unzip \
	spamassassin \
	acl \
	razor pyzor

RUN service dovecot stop
RUN service postfix stop
RUN service opendkim stop
RUN service amavisd-new stop

RUN mkdir /mailserver
WORKDIR /mailserver

#COPY FILES
COPY config_files.sh config_files.sh
COPY init.sh init.sh
COPY config_files config_files/
COPY care_scripts care_scripts/
COPY addAlias.sh addAlias.sh

#SET WORKDIR
WORKDIR /mailserver

RUN ./init.sh


# SMTP ports
EXPOSE 25
EXPOSE 587  
# POP and IMAP ports  
EXPOSE 110
EXPOSE 143
EXPOSE 995
EXPOSE 993

#START EVERYTHING
RUN service dovecot start
RUN service amavisd-new start
RUN service amavisd-milter start
RUN service opendkim start
RUN service postfix start



