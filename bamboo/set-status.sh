#!/bin/bash

source .bamboo_env_vars || true

for REPO in CIRRUS-NSIDC CIRRUS-core; do
    SHA_VAR=${REPO}_SHA
    SHA_VAR=${SHA_VAR/-/_} # - to _
    SHA_VAR=${SHA_VAR^^} # to upper case
    GIT_SHA=${!SHA_VAR}

    URL="https://api.github.com/repos/${ORG}/${REPO}/statuses/${GIT_SHA}"

    echo "POSTing status to ${URL}"

    curl \
        -H "Authorization: token ${GITHUB_TOKEN_SECRET}" \
        -H "Content-Type: application/json" \
        -d "{\"state\":\"${STATUS}\", \"target_url\": \"${TARGET_URL}\", \"description\": \"${DESCRIPTION}\", \"context\": \"${CONTEXT}\"}"\
        -X POST\
        ${URL}
done
