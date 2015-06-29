#!/bin/bash


# Quickly start ansible-playbook without forgetting a required parameter.

usage() {
  EXIT_CODE=${1:0}
  echo "Usage: run.sh ENV [ANSIBLE_OPTIONS] PLAYBOOK"
  exit $EXIT_CODE
}


CURRENT_ENV=$1; shift

if [ -z $CURRENT_ENV ] || [ ! -d "env/${CURRENT_ENV}" ]; then
  echo "Invalid environment: ${CURRENT_ENV}"
  usage 1;
fi

VAULT_PW="$HOME/.ansible/vault-pw-${CURRENT_ENV}"
if [ ! -f "${VAULT_PW}" ]; then
  echo "Invalid vault password file: ${VAULT_PW}"
  usage 1;
fi

if [ ! -d "$HOME/.aws" ]; then
  echo "Missing AWS credentials"
  usage 1;
fi

if [ $(ssh-add -L | grep -q "${CURRENT_ENV}_id_rsa"; echo $?) != 0 ]; then
  ssh-add "env/${CURRENT_ENV}/files/${CURRENT_ENV}_id_rsa"
fi

ansible-playbook                        \
    -vvvv                               \
    -e env=${CURRENT_ENV}               \
    -i "env/${CURRENT_ENV}/inventory"   \
    --vault-password-file="${VAULT_PW}" \
    "$@"
