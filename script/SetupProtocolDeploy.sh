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

APP_ADMIN=$(sed -n 's/ANVIL_ADDRESS_1=//p' .env)
APP_ADMIN_PRIVATE_KEY=$(sed -n 's/ANVIL_PRIVATE_KEY_1=//p' .env) 
os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^APP_ADMIN=.*/APP_ADMIN='$APP_ADMIN'/g' $ENV_FILE
  sed -i '' 's/^APP_ADMIN_PRIVATE_KEY=.*/APP_ADMIN_PRIVATE_KEY='$APP_ADMIN_PRIVATE_KEY'/g' $ENV_FILE
else
  sed -i 's/^APP_ADMIN=.*/APP_ADMIN='$APP_ADMIN'/g' $ENV_FILE
  sed -i 's/^APP_ADMIN_PRIVATE_KEY=.*/APP_ADMIN_PRIVATE_KEY='$APP_ADMIN_PRIVATE_KEY'/g' $ENV_FILE
fi

CONFIG_APP_ADMIN=$(sed -n 's/ANVIL_ADDRESS_4=//p' .env)
CONFIG_APP_ADMIN_KEY=$(sed -n 's/ANVIL_PRIVATE_KEY_4=//p' .env)

os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^CONFIG_APP_ADMIN=.*/CONFIG_APP_ADMIN='$CONFIG_APP_ADMIN'/g' $ENV_FILE
  sed -i '' 's/^CONFIG_APP_ADMIN_KEY=.*/CONFIG_APP_ADMIN_KEY='$CONFIG_APP_ADMIN_KEY'/g' $ENV_FILE
else
  sed -i 's/^CONFIG_APP_ADMIN=.*/CONFIG_APP_ADMIN='$CONFIG_APP_ADMIN'/g' $ENV_FILE
  sed -i 's/^CONFIG_APP_ADMIN_KEY=.*/CONFIG_APP_ADMIN_KEY='$CONFIG_APP_ADMIN_KEY'/g' $ENV_FILE
fi

LOCAL_RULE_ADMIN=$(sed -n 's/ANVIL_ADDRESS_3=//p' .env)
LOCAL_RULE_ADMIN_KEY=$(sed -n 's/ANVIL_PRIVATE_KEY_3=//p' .env) 
os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^LOCAL_RULE_ADMIN=.*/LOCAL_RULE_ADMIN='$LOCAL_RULE_ADMIN'/g' $ENV_FILE
  sed -i '' 's/^LOCAL_RULE_ADMIN_KEY=.*/LOCAL_RULE_ADMIN_KEY='$LOCAL_RULE_ADMIN_KEY'/g' $ENV_FILE
else
  sed -i 's/^LOCAL_RULE_ADMIN=.*/LOCAL_RULE_ADMIN='$LOCAL_RULE_ADMIN'/g' $ENV_FILE
  sed -i 's/^LOCAL_RULE_ADMIN_KEY=.*/LOCAL_RULE_ADMIN_KEY='$LOCAL_RULE_ADMIN_KEY'/g' $ENV_FILE
fi