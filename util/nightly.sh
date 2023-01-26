#!/usr/bin/env sh
set -e

readonly image=crystallang/crystal:nightly
readonly code=/project

docker run -it -v "$PWD:${code}" -w "${code}" "${image}" crystal spec "$@"
