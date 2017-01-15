FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

RUN apt-get update && apt-get install -y \
	cron \
	openssl \
	git \
	dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql dovecot-sieve dovecot-managesieved dovecot-antispam \
	postfix postfix-mysql \
	opendkim opendkim-tools \
	amavisd-new libdbi-perl libdbd-mysql-perl

RUN service dovecot stop
RUN service postfix stop
RUN service opendkim stop
RUN service amavisd-new stop

RUN ./init.sh


#OUR MYSQL should be named mysql

#OPENDKIM Keys folder should be exposed


