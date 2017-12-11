#!/bin/bash

if [[ $CI == true ]]; then
  set -ev
else
  set -e
fi

if [[ $TRAVIS_EVENT_TYPE != "push" ]]; then
  echo "Build is not a push -- skipping!"
  exit 0
fi

if [[ $TRAVIS_BRANCH == "master" ]]; then
  chmod +x scripts/deploy_pub.sh
  scripts/deploy_pub.sh
else
  chmod +x scripts/deploy_pr.sh
  scripts/deploy_pr.sh
fi