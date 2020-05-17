#!/bin/bash
set -e

ver=${1:?"directory required"}
name=${2:-baverman/$ver}

if [ -n "$PROXY" ]; then
    proxy_opts="--build-arg=http_proxy=$PROXY --build-arg=HTTP_PROXY=$PROXY"
fi

test -f $ver/options && source $ver/options

docker build --network=host $proxy_opts $OPTS -t $name ${CONTEXT:-$ver}
docker run --rm $name python -c 'import ssl, sqlite3, zlib'
docker run --rm $name pip freeze

test -n "$TAG" && docker tag $name "$name:$TAG"

if [ -n "$PUSH" ]; then
    docker push $name
fi
