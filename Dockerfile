FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

ENV LETSENCRYPT_PATH /etc/letsencrypt/live/
ENV MAIL_SERVER_DOMAIN mail.example.com

ENV SQL_PASSWORD SQLPASSWORD
ENV SPAM_PASS SPAMPASSWORD

#DO NOT EDIT BELOW
ENV DEBIAN_FRONTEND noninteractive
ENV VMAILHOME /var/vmail/
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
	gettext

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
CMD ./start.sh
