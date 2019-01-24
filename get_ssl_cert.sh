#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SITE_DIR="$DIR/site"

POSITIONAL=("--site-dir $SITE_DIR")
DOMAINS=()

OUT_DIR="$DIR/ssl"
INFO=false
TEST=false
PROD=false

while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        --test)
            TEST=true
            PROD=false
            INFO=false
            REVOKE=false
            shift
            ;;
        --info)
            INFO=true
            PROD=false
            TEST=false
            REVOKE=false
            shift
            ;;
        --prod)
            PROD=true
            TEST=false
            INFO=false
            REVOKE=false
            shift
            ;;
        --revoke)
            REVOKE=true
            PROD=false
            TEST=false
            INFO=false
            shift
            ;;
        --skip-dh)
            SKIP_DH=true
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
    if [ "$INFO" = false ] && [ "$REVOKE" = false ]
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

# Create nginx config file with provided domains as server_name.
ESCAPED_DOMAINS="$(echo "${DOMAINS[@]}" | sed "s/\./\\\./g")"
sed "s/server_name.*name.*/server_name $ESCAPED_DOMAINS;/" "${DIR}/misc/base.conf" > "${DIR}/nginx.conf"

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

    if [ ! -z ${SKIP_DH+x} ]
    then
        # Generate a 2048 bit DH param file.
        # See: https://security.stackexchange.com/questions/94390/whats-the-purpose-of-dh-parameters.
        openssl dhparam -out "${DIR}/ssl/dhparam-2048.pem" 2048
    fi
elif [ "$REVOKE" = true ]
then
    bash "${DIR}/bin/revoke.sh" $@
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
