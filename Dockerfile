FROM ghcr.io/foundry-rs/foundry

RUN apk update
RUN apk add make git python3 py3-pip

WORKDIR /usr/local/src/tron

COPY . /usr/local/src/tron/

RUN pip install -r requirements.txt