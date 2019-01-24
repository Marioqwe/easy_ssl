#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SSL_DIR="${DIR}/ssl"
SITE_DIR="${DIR}/site"
mkdir -p "$SSL_DIR"

POSITIONAL=("--ssl-dir ${SSL_DIR} --site-dir ${SITE_DIR}")
DOMAINS=()
INFO=false
TEST=false
PROD=false

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

set -- "${POSITIONAL[@]}"

# Create nginx config file with provided domains as server_name.
ESCAPED_DOMAINS="$(echo "${DOMAINS[@]}" | sed "s/\./\\\./g")"
sed "s/server_name.*name.*/server_name $ESCAPED_DOMAINS;/" "${DIR}/misc/base.conf" > "${DIR}/nginx.conf"

# Spin up the docker container with the basic nginx server.
docker-compose -f "${DIR}/docker-compose.yml" up -d > /dev/null 2>&1

if [[ ${TEST} = true  ]]
then
    bash "${DIR}/bin/test.sh" $@
elif [[ ${INFO} = true ]]
then
    bash "${DIR}/bin/info.sh" $@
elif [[ ${PROD} = true ]]
then
    bash "${DIR}/bin/run.sh" $@

    # Generate a 2048 bit DH param file.
    # See: https://security.stackexchange.com/questions/94390/whats-the-purpose-of-dh-parameters.
    openssl dhparam -out "${DIR}/ssl/dhparam-2048.pem" 2048
else
    echo "Error: no mode provided."
    HAS_ERROR=true
fi

# Bring down docker container.
docker-compose -f "${DIR}/docker-compose.yml" down > /dev/null 2>&1

if [[ ${HAS_ERROR} = true ]]
then
    exit -1
fi
