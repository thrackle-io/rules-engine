################################################
# 
# `foundry-base` layer is where we build our own foundry container to use as a base image for
# anything that needs to use forge/anvil/cast/etc. Since foundry's release process is so prone
# to breaking things, we have opted to directly compile foundry from github using cargo, pinned to
# a specific commit hash in their repo, thus avoiding all the issues we've had with their release
# process and wacky install scripts.
#
# This layer is cached and not re-built unless there is some change to either foundry.lock
# or docker-scripts/install-forge.sh. It may be necessary to specifically update your Docker 
# settings to increase the max available memory in a container for this base stage to successfully
# build. 
#
################################################

FROM rust:1.78.0-bookworm as foundry-base

RUN apt update
RUN apt install -y curl unzip git make procps python3 python3-pip python3.11-venv jq gh npm

WORKDIR /usr/local/src/tron

RUN mkdir docker-scripts/
COPY foundry.lock .
COPY docker-scripts/install-forge.sh docker-scripts/

RUN chmod a+x ./docker-scripts/install-forge.sh
RUN ./docker-scripts/install-forge.sh

################################################
#
# `compile-tron` layer pulls all of the tron repo into the container
# and then runs `forge build` to compile it. This stage will rebuild any 
# time any file in the tron repo changes, including this Dockerfile and
# any of the docker-scripts/ 
#
################################################

FROM foundry-base as compile-tron
COPY . .
RUN chmod -R a+x docker-scripts
RUN ./docker-scripts/compile-tron.sh

################################################
#
# `anvil` layer is just the compiled tron layer, 
# running anvil 
#
# FOUNDRY_PROFILE selects a profile from foundry.toml
# RUST_LOG configures anvil output information. I think. 
#
################################################

FROM compile-tron as anvil
ENV FOUNDRY_PROFILE=docker
ENV RUST_LOG=backend,api,node,rpc=warn
CMD ["./docker-scripts/run-anvil.sh"]

################################################
#
# `deploy-tron` layer runs the tron deploy scripts
# to deploy tron to the anvil container which should
# be run along side it. the deploy-tron.sh script
# finishes by tail'ing /dev/null so that this container
# will stay alive and running after the deploy, which
# allows tron devs to use it for running tests and other
# forge/cast commands easily.
#
# FOUNDRY_PROFILE selects a profile from foundry.toml
#
################################################

FROM compile-tron as deploy-tron
ENV FOUNDRY_PROFILE=docker
CMD ["./docker-scripts/deploy-tron.sh"]

################################################
#
# `necessist` layer is for running the tron necessist testing process
#
################################################

FROM compile-tron as tron-necessist

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

CMD ["./docker-scripts/run-necessist.sh"]

