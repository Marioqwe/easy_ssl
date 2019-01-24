#!/bin/bash

# Get additional information about certificates at the specified location.

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
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

docker run --rm -it --name certbot \
-v "${OUT_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "${OUT_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
certbot/certbot certificates
