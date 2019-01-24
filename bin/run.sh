#!/bin/bash

# This script starts a Certbot docker container that will run the
# ACME challenge. If successful, Certbot will place two files in
# /etc/letsencrypt/live/perunews.xyz: the certificate fullchain.pem, and the
# certificate's key private.pem.

POSITIONAL=()

while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        --ssl-dir)
            SSL_DIR=$2
            shift
            shift
            ;;
        --site-dir)
            SITE_DIR=$2
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [ -z ${SSL_DIR+x} ];
then
    echo "InternalError: missing 'ssl' directory."
    exit -1
fi

if [ -z ${SITE_DIR+x} ];
then
    echo "InternalError: missing 'site' directory."
    exit -1
fi

set -- "${POSITIONAL[@]}"

docker run -it --rm \
-v "${SSL_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "${SSL_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "${SSL_DIR}"/var/log/letsencrypt:/var/log/letsencrypt \
-v "${SITE_DIR}":/data/letsencrypt \
certbot/certbot \
certonly --webroot \
--webroot-path=/data/letsencrypt \
--agree-tos --no-eff-email "$@"
