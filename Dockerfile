#----------------------------------------------------------------------------------------------
# Variables used for image building

ARG KEY_DB_VERSION=x86_64_v6.3.4

#----------------------------------------------------------------------------------------------
# Setup base image with build tooling

FROM debian:11-slim AS builder
WORKDIR /keydb
RUN apt update && apt install -y build-essential git cmake python3 python3-pip curl rustc cargo
RUN pip config set global.trusted-host "pypi.org pypa.io files.pythonhosted.org pypi.python.org"

#----------------------------------------------------------------------------------------------
# Setup certs for fetching deps

RUN bash -c 'echo -e Add Enterprise Certs here if behind vpn'

#----------------------------------------------------------------------------------------------
# Variables used for module building

ARG REDISJSON_VERSION=v2.6.4
ARG REDISEARCH_VERSION=v2.6.15

#----------------------------------------------------------------------------------------------
# Build Redis Search Module for KeyDB

RUN git clone -b ${REDISEARCH_VERSION} --recursive https://github.com/RediSearch/RediSearch.git RediSearch && \
    git submodule update --recursive --init
RUN RediSearch/deps/readies/bin/system-setup.py
RUN cd RediSearch && make setup && make build

#----------------------------------------------------------------------------------------------
# Build Redis JSON Module for KeyDB

RUN git clone -b ${REDISJSON_VERSION} --recursive  https://github.com/RedisJSON/RedisJSON.git RedisJSON && \
    git submodule update --recursive --init
RUN RedisJSON/deps/readies/bin/system-setup.py
RUN cd RedisJSON && make setup && make build

#----------------------------------------------------------------------------------------------
# Configure and start KeyDB Image with Redis Modules

FROM eqalpha/keydb:${KEY_DB_VERSION} AS prod
ADD keydb.conf /etc/keydb.conf
COPY --from=builder /keydb/bin/linux-x64-release/search/redisearch.so /etc/libs/redisearch.so
COPY --from=builder /keydb/RedisJSON/bin/linux-x64-release/search/rejson.so /etc/libs/rejson.so

EXPOSE 6379
CMD ["keydb-server", "/etc/keydb.conf"]