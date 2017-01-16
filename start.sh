#!/bin/bash

echo "STARTING SERVICES"
service dovecot start
systemctl start amavisd-new
systemctl start amavisd-milter
service opendkim start
service postfix start
