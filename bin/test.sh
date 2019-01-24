#!/bin/bash

# Staging command for issuing new certificate.
#
# The sole purpose of this script is to make sure the
# certbot commands will execute properly before running
# the actual commands. That way we'll not use up
# our '20 certificates / 7 days' limit.

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
        --email)
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
--register-unsafely-without-email --agree-tos \
--staging "$@"
