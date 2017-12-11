#!/bin/bash

set -ev

LAST_TAG=$(git describe --abbrev=0 --tags)
DATA="{\"title\":\"Release version $LAST_TAG\",\"head\":\"$TRAVIS_BRANCH\",\"base\":\"master\"}"
URL="https://api.github.com/repos/$TRAVIS_REPO_SLUG/pulls"

echo "Creating PR with data:"
echo "> $DATA"
echo "> $URL"

curl -u "$BOT_NAME:$BOT_PWD" -H "Content-Type: application/json" -X POST -d "$DATA" "$URL" --fail