#!/bin/bash

if [[ $CI == true ]]; then
  set -ev
else
  set -e
fi

grind test