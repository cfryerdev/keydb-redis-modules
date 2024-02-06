#----------------------------------------------------------------------------------------------
# Setup base image with build tooling

FROM debian:11-slim AS builder
WORKDIR /keydb
RUN apt update && apt install -y build-essential git cmake python3 python3-pip

#----------------------------------------------------------------------------------------------
# Setup certs for fetching deps

# Add Enterprise Certs here if behind zscaler

#----------------------------------------------------------------------------------------------
# Variables used for image building

ARG REDISJSON_VERSION=v2.6.8
ARG REDISEARCH_VERSION=v2.6.12
ENV REDISEARCH_VERSION=${REDISEARCH_VERSION}
ENV REDISJSON_VERSION=${REDISJSON_VERSION}

#----------------------------------------------------------------------------------------------
# Build Redis Search Module for KeyDB

RUN git clone -b ${REDISEARCH_VERSION} --recursive https://github.com/RediSearch/RediSearch.git . && \
    git submodule update --recursive --init
RUN ./deps/readies/bin/system-setup.py
RUN pip config set global.trusted-host "pypi.org pypa.io files.pythonhosted.org pypi.python.org"
RUN make setup
RUN make build

#----------------------------------------------------------------------------------------------
# Build KeyDB Image with Redis Modules

FROM eqalpha/keydb:latest AS prod 
ADD keydb.conf /etc/keydb.conf
COPY --from=builder /keydb/bin/linux-x64-release/search/redisearch.so /etc/libs/redisearch.so

#----------------------------------------------------------------------------------------------
# Run the image with the exposed port and config

EXPOSE 6379
CMD ["keydb-server", "/etc/keydb.conf"]
