#!/bin/bash

ENV_FILE=".env"


APPLICATION_ERC721U_ADDRESS=$(sed -n 's/APPLICATION_ERC721U_ADDRESS=//p' .env)
APPLICATION_ERC721U_HANDLER=$(sed -n 's/APPLICATION_ERC721U_HANDLER=//p' .env)

os=$(uname -a)
if [[ $os == *"Darwin"* ]]; then
  sed -i '' 's/^APPLICATION_ERC721_ADDRESS_1=.*/APPLICATION_ERC721_ADDRESS_1='$APPLICATION_ERC721U_ADDRESS'/g' $ENV_FILE
  sed -i '' 's/^APPLICATION_ERC721_HANDLER=.*/APPLICATION_ERC721_HANDLER='$APPLICATION_ERC721U_HANDLER'/g' $ENV_FILE
else
  sed -i 's/^APPLICATION_ERC721_ADDRESS_1=.*/APPLICATION_ERC721_ADDRESS_1='$APPLICATION_ERC721U_ADDRESS'/g' $ENV_FILE
  sed -i 's/^APPLICATION_ERC721_HANDLER=.*/APPLICATION_ERC721_HANDLER='$APPLICATION_ERC721U_HANDLER'/g' $ENV_FILE
fi