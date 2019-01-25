#!/bin/bash

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
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

docker run -it --rm \
-v "${OUT_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "${OUT_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "${OUT_DIR}"/var/log/letsencrypt:/var/log/letsencrypt \
-v "${SITE_DIR}":/data/letsencrypt \
certbot/certbot \
renew --webroot \
--webroot-path=/data/letsencrypt \
--quiet
