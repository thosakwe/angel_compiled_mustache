#!/bin/bash

if [[ $CI == true ]]; then
  set -ev
else
  set -e
fi

echo "ae:$ANGEL_ENV"
export ANGEL_ENV=production
grind test