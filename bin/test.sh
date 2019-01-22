#!/bin/bash

# Staging command for issuing new certificate.
#
# The sole purpose of this script is to make sure the
# certbot commands will execute properly before running
# the actual commands. That way we'll not use up
# our '20 certificates / 7 days' limit.

docker run -it --rm \
-v "$(pwd)"/ssl/etc/letsencrypt:/etc/letsencrypt \
-v "$(pwd)"/ssl/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "$(pwd)"/ssl/var/log/letsencrypt:/var/log/letsencrypt \
-v "$(pwd)"/site:/data/letsencrypt \
certbot/certbot \
certonly --webroot \
--webroot-path=/data/letsencrypt \
--register-unsafely-without-email --agree-tos \
--staging "$@"
