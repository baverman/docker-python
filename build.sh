#!/bin/bash
set -e

ver=${1:?"directory required"}
name=${2:-baverman/$ver}

docker build -t $name $ver
docker push $name
