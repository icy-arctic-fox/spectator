#!/usr/bin/env bash
set -e

find spec/ -type f -name \*_spec.cr -print0 | \
  xargs -0 -n1 crystal spec --error-on-warnings -v
