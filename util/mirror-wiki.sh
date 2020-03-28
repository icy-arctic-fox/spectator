#!/usr/bin/env bash
set -ex

# Mirrors the contents of the GitLab wiki to GitHub.
git clone git@gitlab.com:arctic-fox/spectator.wiki.git
pushd spectator.wiki
git remote add github git@github.com:icy-arctic-fox/spectator.wiki.git
git fetch github
git push github master
popd
rm -rf spectator.wiki
