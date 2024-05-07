################################################
# 
# `foundry-base` layer is where we build our own foundry container to build
# anything that needs to use it. Since foundry's release process is so prone
# to breaking things, we have opted to directly download foundryup from github
# and use that to compile it ourselves from a specific commit hash (specified in foundry.lock)
# This way we avoid all the unnecessary logic which is included in their download script,
# and we avoid any hassles created by their random deletions of nightly releases... 
#
# This layer should be cached and not re-built unless there is some change to either foundry.lock
# or docker-scripts/install-forge.sh. 
#
################################################

FROM rust:1.78-bookworm as foundry-base

RUN apt update
RUN apt install -y curl unzip git make procps python3 python3-pip python3.11-venv jq gh

WORKDIR /usr/local/src/tron

RUN mkdir docker-scripts/
COPY foundry.lock .
COPY docker-scripts/install-forge.sh docker-scripts/

RUN curl -L https://foundry.paradigm.xyz | bash
RUN chmod a+x ./docker-scripts/install-forge.sh
RUN ./docker-scripts/install-forge.sh

################################################
#
# `compile-tron` layer pulls all of the tron repo into the container
# and then runs `forge build` to compile it. This stage will rebuild any 
# time any tron code changes. 
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
################################################

FROM compile-tron as anvil
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
################################################

FROM compile-tron as deploy-tron
CMD ["./docker-scripts/deploy-tron.sh"]