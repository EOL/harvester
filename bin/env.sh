#!/bin/bash
set -o allexport
source /app/docker/.env
set +o allexport
git config --global user.email $EOL_GITHUB_EMAIL
git config --global user.name $EOL_GITHUB_USER
