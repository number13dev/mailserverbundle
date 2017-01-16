FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

ENV LETSENCRYPT_PATH /etc/letsencrypt/live/
ENV MAIL_SERVER_DOMAIN mail.mysystems.tld

ENV SQL_PASSWORD SQLPASSWORD
ENV SPAM_PASS SPAMPASSWORD

ENV DEBIAN_FRONTEND noninteractive

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
	gettext

RUN service dovecot stop
RUN service postfix stop
RUN service opendkim stop
#RUN systemctl stop amavisd-new

RUN mkdir /mailserver
WORKDIR /mailserver

#COPY FILES
COPY config_files.sh /mailserver/config_files.sh
COPY init.sh /mailserver/init.sh
COPY config_files /mailserver/config_files/
COPY care_scripts /mailserver/care_scripts/
COPY addAlias.sh /mailserver/addAlias.sh

RUN ./config_files.sh

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
RUN systemctl start amavisd-new
RUN systemctl start amavisd-milter
RUN service opendkim start
RUN service postfix start
