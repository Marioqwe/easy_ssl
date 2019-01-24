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
        --out-dir)
            OUT_DIR=$2
            shift
            shift
            ;;
        --site-dir)
            SITE_DIR=$2
            shift
            shift
            ;;
        --email)
            EMAIL=$2
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [ -z ${EMAIL+x} ];
then
    POSITIONAL+=("--register-unsafely-without-email")
else
    POSITIONAL+=("--email $EMAIL --no-eff-email")
fi

set -- "${POSITIONAL[@]}"

docker run -it --rm \
-v "${OUT_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "${OUT_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "${OUT_DIR}"/var/log/letsencrypt:/var/log/letsencrypt \
-v "${SITE_DIR}":/data/letsencrypt \
certbot/certbot \
certonly --webroot \
--webroot-path=/data/letsencrypt \
--agree-tos "$@"
