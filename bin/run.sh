#!/bin/bash

# This script starts a Certbot docker container that will run the
# ACME challenge. If successful, Certbot will place two files in
# /etc/letsencrypt/live/perunews.xyz: the certificate fullchain.pem, and the
# certificate's key private.pem.

docker run -it --rm \
-v "$(pwd)"/ssl/etc/letsencrypt:/etc/letsencrypt \
-v "$(pwd)"/ssl/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "$(pwd)"/ssl/var/log/letsencrypt:/var/log/letsencrypt \
-v "$(pwd)"/site:/data/letsencrypt \
certbot/certbot \
certonly --webroot \
--webroot-path=/data/letsencrypt \
--agree-tos --no-eff-email "$@"
