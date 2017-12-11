#!/bin/bash

set -ev

DATA="{\"title\":\"It's working! ($TRAVIS_JOB_NUMBER)\",\"head\":\"$TRAVIS_BRANCH\",\"base\":\"master\"}"
URL="https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls"

echo "Creating PR with data:"
echo "> $DATA"
echo "> $URL"

curl -u "$BOT_NAME:$BOT_PWD" -H "Content-Type: application/json" -X POST -d "$DATA" "$URL"