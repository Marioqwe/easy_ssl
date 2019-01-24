#!/bin/bash

# Get additional information about certificates at the specified location.

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

docker run --rm -it --name certbot \
-v "{SSL_DIR}"/etc/letsencrypt:/etc/letsencrypt \
-v "{SSL_DIR}"/var/lib/letsencrypt:/var/lib/letsencrypt \
certbot/certbot certificates
