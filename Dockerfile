FROM ubuntu

MAINTAINER Johannes <johannes@number13.de>

RUN apt-get update && apt-get install -y \
	cron \
	openssl \
	git
	

RUN echo "mail" > /etc/hostname
RUN echo "mail.pccg.de" > /etc/mailname
RUN mkdir /etc/myssl

RUN crontab -l > mycron
RUN echo "@daily FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem" >> mycron
RUN crontab mycron
RUN rm mycron

RUN FILE=`mktemp` ; openssl dhparam 2048 -out $FILE && mv -f $FILE /etc/myssl/dh2048.pem

RUN git clone https://github.com/certbot/certbot
WORKDIR /certbot
RUN ./certbot-auto -n

