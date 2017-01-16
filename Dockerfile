FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

ENV LETSENCRYPT_PATH /etc/letsencrypt/live/
ENV MAIL_SERVER_DOMAIN mail.example.com
ENV SERVER_DOMAIN example.com

ENV SQL_PASSWORD SQLPASSWORD
ENV SPAM_PASS SPAMPASSWORD

#DO NOT EDIT BELOW
ENV DEBIAN_FRONTEND noninteractive


ENV CF_PATH /mailserver/config_files/
ENV SUBSTITUED_CF_PATH /mailserver/subs_files/
ENV CARE_SCRIPT_PATH /mailserver/care_scripts/

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
	razor pyzor \
	gettext \
	wget \
	letsencrypt

RUN service dovecot stop
RUN service postfix stop
RUN service opendkim stop

RUN mkdir /mailserver
WORKDIR /mailserver

#COPY FILES
COPY config_files.sh /mailserver/config_files.sh
COPY init.sh /mailserver/init.sh
COPY addAlias.sh /mailserver/addAlias.sh
COPY start.sh /mailserver/start.sh
COPY init_db.sh /mailserver/init_db.sh

COPY config_files /mailserver/config_files/
COPY care_scripts /mailserver/care_scripts/

# Enables Pyzor and Razor
USER amavis
RUN razor-admin -create && razor-admin -register && pyzor discover
USER root

RUN ./init.sh


RUN chown -R vmail:root /etc/letsencrypt/live/

#expose ports
EXPOSE 25 587 110 143 995 991

#START EVERYTHING
CMD ./start.sh
