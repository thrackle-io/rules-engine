################################################
# 
# `foundry-base` layer is where we build our own foundry container to use as a base image for
# anything that needs to use forge/anvil/cast/etc. This uses thrackle-io/foundry to install
# numbered versions of foundry's tools, using a modified `foundryup` and a foundry.lock file.
# The Foundry tools are installed as precompiled binaries providing a fast build time.
#
# This layer is cached and not re-built unless there is a change to foundry.lock.
################################################

FROM rust:1.78.0-bookworm as foundry-base

RUN apt update
RUN apt install -y curl unzip git make procps python3 python3-pip python3.11-venv jq gh npm

WORKDIR /usr/local/src/forte-rules-engine

COPY script/foundryScripts/foundry.lock .

## Install Foundry via Thrackle's foundryup, using version set in foundry.lock (awk ignores comments)
RUN curl -sSL https://raw.githubusercontent.com/thrackle-io/foundry/refs/heads/master/foundryup/foundryup -o foundryup && \
  FOUNDRY_DIR=/usr/local bash ./foundryup --version $(awk '$1~/^[^#]/' foundry.lock)


################################################
#
# `compile` layer pulls all of the repo into the container
# and then runs `forge build` to compile it. This stage will rebuild any 
# time any file in the repo changes, including this Dockerfile and
# any of the script/docker/ files
#
################################################

FROM foundry-base as compile
COPY . .
RUN chmod -R a+x script/docker
RUN script/docker/compile.sh


################################################
#
# `anvil` layer is just the compiled layer, 
# running anvil 
#
# FOUNDRY_PROFILE selects a profile from foundry.toml
# RUST_LOG configures anvil output information. I think. 
# CHAIN_ID is the chain-id Anvil runs on
#
################################################

FROM compile as anvil
ENV FOUNDRY_PROFILE=docker
ENV RUST_LOG=backend,api,node,rpc=warn
ENV CHAIN_ID=31337
ENTRYPOINT anvil --host 0.0.0.0 --chain-id $CHAIN_ID


################################################
#
# `check-deploy` layer runs the docker deploy script 
# in "deploy check" mode, so that the results of the deploy 
# can be parsed and confirmed as having worked.
#
################################################

FROM compile as check-deploy
ENV FOUNDRY_PROFILE=local
CMD ["script/docker/check-deploy.sh"]


################################################
#
# `deploy` layer runs the deploy scripts
# to deploy to the anvil container which should
# be run along side it. the deploy.sh script
# finishes by tail'ing /dev/null so that this container
# will stay alive and running after the deploy, which
# allows devs to use it for running tests and other
# forge/cast commands easily.
#
# FOUNDRY_PROFILE selects a profile from foundry.toml
#
################################################

FROM compile as deploy
ENV FOUNDRY_PROFILE=docker
CMD ["script/docker/deploy.sh"]


################################################
#
# `necessist` layer is for running the necessist testing process
#
################################################

FROM compile as necessist

RUN cargo install necessist

## Install AWS CLI and set up credentials so the db file that results from 
## necessist running can be uploaded to s3.

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_REGION

ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_REGION}

CMD ["src/docker/run-necessist.sh"]
