#!/bin/bash

# Get additional information about certificates at the specified location.

docker run --rm -it --name certbot \
-v "$(pwd)"/ssl/etc/letsencrypt:/etc/letsencrypt \
-v "$(pwd)"/ssl/var/lib/letsencrypt:/var/lib/letsencrypt \
-v "$(pwd)"/site:/data/letsencrypt \
certbot/certbot \
--staging \
certificates "$@"
