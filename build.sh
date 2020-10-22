#!/usr/bin/env bash

set -x

echo "Building skynewz/runitor:latest"
docker buildx build \
--tag skynewz/runitor:latest \
--push \
--platform darwin/amd64,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64 \
--build-arg RUNITOR_VERSION=${RUNITOR_VERSION} \
--build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
.

echo "Building skynewz/runitor:${RUNITOR_VERSION}"
docker buildx build \
--tag skynewz/runitor:${RUNITOR_VERSION} \
--push \
--platform darwin/amd64,linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64 \
--build-arg RUNITOR_VERSION=${RUNITOR_VERSION} \
--build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
.