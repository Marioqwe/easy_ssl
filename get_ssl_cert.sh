#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SITE_DIR="$DIR/site"

POSITIONAL=("--site-dir $SITE_DIR")
DOMAINS=()

OUT_DIR="$DIR/ssl"
DEV_SERVER=false

while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        --test)
            TEST=true
            shift
            ;;
        --info)
            INFO=true
            shift
            ;;
        --prod)
            PROD=true
            shift
            ;;
        --revoke)
            REVOKE=true
            shift
            ;;
        --renew)
            RENEW=true
            shift
            ;;
        --skip-dh)
            SKIP_DH=true
            shift
            ;;
        --dev-server)
            DEV_SERVER=true
            shift
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift
            shift
            ;;
        -d)
            DOMAINS+=("$2")
            POSITIONAL+=("$1")
            POSITIONAL+=("$2")
            shift
            shift
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [ -d "$OUT_DIR" ]
then
    if [ -z ${INFO+x} ] && [ -z ${REVOKE+x} ]
    then
        while true;
        do
            read -p "\"$OUT_DIR\" already exists. Do you wish to continue? " yn
            case $yn in
                [Yy]* ) break ;;
                [Nn]* ) exit -1 ;;
                * ) echo "Please answer yes or no." ;;
            esac
        done
    fi
else
    if [ "$INFO" = true ] || [ "$REVOKE" = true ]
    then
        echo "Error: \"$OUT_DIR\" doesn't exist."
        exit -1
    else
        mkdir -p "$OUT_DIR"
    fi
fi

POSITIONAL+=("--out-dir $OUT_DIR")
set -- "${POSITIONAL[@]}"

if [ "$RENEW" = true ] && [ "$DEV_SERVER" = false ]
then
    bash "${DIR}/bin/renew.sh"
    exit 0
fi

# Create nginx config file.
ESCAPED_DOMAINS="$(echo "${DOMAINS[@]}" | sed "s/\./\\\./g")"
sed "s|server_name.*name.*|server_name $ESCAPED_DOMAINS;|" "${DIR}/misc/base.conf" > "${DIR}/nginx.conf"

unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*) sed -i "" "s|root.*certbot-root.*|root $SITE_DIR;|" "${DIR}/nginx.conf" ;;
    *) sed -i "s|root.*certbot-root.*|root $SITE_DIR;|" "${DIR}/nginx.conf" ;;
esac

# Create docker-compose file.
sed "s|- \./site:<certbot-root>|- \./site:${SITE_DIR}|" "${DIR}/misc/docker-compose.base.yml" > "${DIR}/docker-compose.yml"


# Spin up the docker container with the basic nginx server.
docker-compose -f "${DIR}/docker-compose.yml" up -d > /dev/null 2>&1

if [ "$TEST" = true  ]
then
    bash "${DIR}/bin/test.sh" $@
elif [ "$INFO" = true ]
then
    bash "${DIR}/bin/info.sh" $@
elif [ "$PROD" = true ]
then
    bash "${DIR}/bin/run.sh" $@

    if [ -z ${SKIP_DH+x} ]
    then
        # Generate a 2048 bit DH param file.
        # See: https://security.stackexchange.com/questions/94390/whats-the-purpose-of-dh-parameters.
        openssl dhparam -out "${DIR}/ssl/dhparam-2048.pem" 2048
    fi
elif [ "$REVOKE" = true ]
then
    bash "${DIR}/bin/revoke.sh" $@
elif [ "$RENEW" = true ]
then
    bash "${DIR}/bin/renew.sh"
else
    echo "Error: no mode provided."
    HAS_ERROR=true
fi

# Bring down docker container.
docker-compose -f "${DIR}/docker-compose.yml" down > /dev/null 2>&1

if [ "$HAS_ERROR" = true ]
then
    exit -1
fi
