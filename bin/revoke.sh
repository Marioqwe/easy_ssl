#!/bin/bash

# Remove certificate at the specified location.

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
            shift
            shift
            ;;
        -d)
            DOMAIN=$2
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

docker run --rm -it --name certbot \
-v "${OUT_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "${OUT_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
certbot/certbot revoke --cert-path /etc/letsencrypt/live/"${DOMAIN}"/cert.pem "$@"
