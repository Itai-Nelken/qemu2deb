#!/bin/bash

while [[ $# != 0 ]]; do
  case "$1" in
    -h|--help)
      echo "TEST_SCRIPT to test flags."
      echo " "
      echo "./1.sh [options]"
      echo " "
      echo "options:"
      echo "-h, --help             show this help."
      echo "--input="some-text"    test to get text from a flag."
      exit 0
      ;;
    -i* | --input*)
      export TEST=$(echo $1 | sed -e 's/^[^=]*=//g')
      shift
      ;;
    *)
      echo "invalid option '$1'!"
      break
      ;;
  esac
done

echo $TEST
