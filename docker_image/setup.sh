#!/bin/bash


# Setup to run the ACME example Ansible project

# By default, it is set for the "dev" environment. If you want to use another,
# like "prod", you can pass it in on the command line:
#
#    ./setup.sh prod
#
# To actually make a new environment, create the directory first:
#
# 1. cp -R env/dev env/new_env      (from a clean version of dev, unused)
# 2. edit env/new_env/group_vars/all and set "env: new_env"
# 3. If you want new SSH keys created, remove the id_rsa files from ~/.ssh/
# 4. /root/setup.sh new_env


# Can't set these on the shebang line when Docker invokes the script.
set -u
set -e
set -o pipefail


ANSIBLE_ENV=${1:-dev}

# Capture any existing ENV vars we care about
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
AWS_REGION=${AWS_REGION:-}
VAULT_PW=${VAULT_PW:-}


# Check to see we're running in the Docker image
if [ ! -f /root/setup.sh ] &&
   [ ! -d /root/acme ]     &&
   [ ! -d /root/conf ]; then
   echo "It appears we are not inside the ACME demo Docker image. This script is"
   echo "written specifically for that environment and is not safe to run elsewhere."
   exit 1;
fi


echo "Ensure the acme repo is up-to-date"
cd /root/acme
git pull


echo "Ansible ACME demo setup"
echo
echo "--Setup AWS"
#   1. AWS_* passed as an ENV vars
#   2. aws_credentials/aws_config files in the conf dir
#   3. generate interactively on container launch
if   [ ! -z $AWS_ACCESS_KEY_ID ]      &&
     [ ! -z $AWS_SECRET_ACCESS_KEY ]; then
    echo "Using AWS credentials from ENV vars"
    ( cat <<EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF
    ) > /root/.aws/credentials

    ( cat <<EOF
[default]
region = $AWS_REGION
output = json
EOF
    ) > /root/.aws/config
elif  [ -f /root/conf/aws_credentials ] &&
      [ -f /root/conf/aws_config ];     then
    echo "Using AWS credentials from /root/conf"
    mkdir -p /root/.aws
    cp -v /root/conf/aws_credentials /root/.aws/credentials
    cp -v /root/conf/aws_config      /root/.aws/config
else
    echo "Using AWS credentials you enter manually"
    aws configure
fi


echo
echo "--Setup SSH"
#   1. id_rsa in ~/.ssh/
#   2. id_rsa in the conf dir
#   3. generate a new key
if [ -f /root/.ssh/id_rsa ]; then
    echo "Using existing SSH keys from /root/.ssh/"
elif  [ -f /root/conf/id_rsa ]; then
    echo "Using SSH keys from /root/conf"
    cp -v /root/conf/id_rsa     /root/.ssh/
    cp -v /root/conf/id_rsa.pub /root/.ssh/
else
    echo "Generating new SSH keypair"
    ssh-keygen -q -t rsa -P '' -f /root/.ssh/id_rsa
fi
chmod -R go-rwx /root/.ssh
cp -vf /root/.ssh/id_rsa     /root/acme/env/${ANSIBLE_ENV}/files/${ANSIBLE_ENV}_id_rsa
cp -vf /root/.ssh/id_rsa.pub /root/acme/env/${ANSIBLE_ENV}/files/${ANSIBLE_ENV}_id_rsa.pub


echo
echo "--Setup Ansible Vault"
#   1. VAULT_PW passed as an ENV var
#   2. vault-pw in the conf dir
#   3. generate interactively on container launch
mkdir -p /root/.ansible
if [ -f /root/acme/env/${ANSIBLE_ENV}/group_vars/secrets.yml ]; then
    echo "Warning! secrets.yml already exists, so skipping this step. If this"
    echo "is an error, delete the file and re-run setup."
    echo "file path: /root/acme/env/${ANSIBLE_ENV}/group_vars/secrets.yml"
elif  [ ! -z $VAULT_PW ]; then
    echo "Using password from VAULT_PW ENV var"
    echo "${VAULT_PW}" > /root/.ansible/vault-pw-${ANSIBLE_ENV}
elif  [ -f /root/conf/vault-pw ]; then
    echo "Using password from /root/conf/vault-pw"
    cp -v /root/conf/vault-pw /root/.ansible/vault-pw-${ANSIBLE_ENV}
else
    echo "Enter a password to be used by ansible-vault for the ${ANSIBLE_ENV} environment"
    while true; do
        read -p "new password: " ANSWER
        case $ANSWER in
          [a-zA-Z0-9]* ) echo "${ANSWER}" > /root/.ansible/vault-pw-${ANSIBLE_ENV}
                         break;;

           * )           echo "";;
        esac
    done
fi
# Now that we have the password, we can encrypt a new secrets file
if [ ! -f /root/acme/env/${ANSIBLE_ENV}/group_vars/secrets.yml ]; then
    cp /root/acme/env/${ANSIBLE_ENV}/group_vars/secrets-example.yml \
       /root/acme/env/${ANSIBLE_ENV}/group_vars/secrets.yml

    ansible-vault --vault-password-file=/root/.ansible/vault-pw-${ANSIBLE_ENV} \
      encrypt /root/acme/env/${ANSIBLE_ENV}/group_vars/secrets.yml
fi

echo
echo "--Setup complete."
