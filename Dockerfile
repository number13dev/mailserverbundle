FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y -qq \
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
	wget

RUN service dovecot stop
RUN service postfix stop
RUN service opendkim stop

ADD config_files config_files
ADD care_scripts care_scripts

# Enables Pyzor and Razor
USER amavis
RUN razor-admin -create && razor-admin -register && pyzor discover
USER root

RUN ./init.sh

#expose ports
EXPOSE 25 587 110 143 995 991

#START EVERYTHING
CMD ./start.sh
