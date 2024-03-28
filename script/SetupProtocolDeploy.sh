#!/bin/bash

ENV_FILE=".env"

OWNER=$(sed -n 's/ANVIL_ADDRESS_0=//p' .env)
OWNER_PRIVATE_KEY=$(sed -n 's/ANVIL_PRIVATE_KEY_0=//p' .env) 

os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^DEPLOYMENT_OWNER=.*/DEPLOYMENT_OWNER='$OWNER'/g' $ENV_FILE
  sed -i '' 's/^DEPLOYMENT_OWNER_KEY=.*/DEPLOYMENT_OWNER_KEY='$OWNER_PRIVATE_KEY'/g' $ENV_FILE
else
  sed -i 's/^DEPLOYMENT_OWNER=.*/DEPLOYMENT_OWNER='$OWNER'/g' $ENV_FILE
  sed -i 's/^DEPLOYMENT_OWNER_KEY=.*/DEPLOYMENT_OWNER_KEY='$OWNER_PRIVATE_KEY'/g' $ENV_FILE
fi