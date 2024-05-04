FROM rust:bookworm as foundry-base

RUN apt update
RUN apt install -y curl unzip git make procps python3 python3-pip python3.11-venv jq gh

WORKDIR /usr/local/src/tron

COPY . .

RUN curl -L https://foundry.paradigm.xyz | bash
RUN chmod a+x install-forge.sh docker-deploy-tron.sh docker-run-anvil.sh

RUN ./install-forge.sh


FROM foundry-base as anvil

CMD ["./docker-run-anvil.sh"]


FROM foundry-base as deploy-tron

CMD ["./docker-deploy-tron.sh"]