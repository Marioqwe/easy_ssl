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
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

set -- "${POSITIONAL[@]}"

docker run -it --rm \
-v "${OUT_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "${OUT_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "${OUT_DIR}"/var/log/letsencrypt:/var/log/letsencrypt \
-v "${SITE_DIR}":/data/letsencrypt \
certbot/certbot \
certonly --webroot \
--webroot-path=/data/letsencrypt \
--register-unsafely-without-email --agree-tos \
--staging $@
