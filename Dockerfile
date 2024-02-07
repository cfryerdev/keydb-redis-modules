#----------------------------------------------------------------------------------------------
# Variables used for image building

ARG KEY_DB_VERSION=x86_64_v6.3.4

#----------------------------------------------------------------------------------------------
# Setup base image with build tooling

FROM debian:11-slim AS builder
WORKDIR /keydb
RUN apt update && apt install -y build-essential git cmake python3 python3-pip curl rustc cargo
RUN pip config set global.trusted-host "pypi.org pypa.io files.pythonhosted.org pypi.python.org"
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup update

#----------------------------------------------------------------------------------------------
# Setup certs for fetching deps

RUN bash -c 'echo -e Add Enterprise Certs here if behind vpn'
# ADD /SomeCACertHere.crt /usr/local/share/ca-certificates/SomeCACertHere.crt
# RUN chmod 644 /usr/local/share/ca-certificates/SomeCACertHere.crt
# RUN update-ca-certificates

#----------------------------------------------------------------------------------------------
# Variables used for module building

ARG REDISJSON_VERSION=v2.6.9
ARG REDISEARCH_VERSION=v2.6.15

#----------------------------------------------------------------------------------------------
# Build Redis Search Module for KeyDB

RUN git clone -b ${REDISEARCH_VERSION} --recursive https://github.com/RediSearch/RediSearch.git RediSearch && \
    cd RediSearch && git submodule update --recursive --init
RUN RediSearch/deps/readies/bin/system-setup.py
RUN cd RediSearch && make setup && make build

#----------------------------------------------------------------------------------------------
# Build Redis JSON Module for KeyDB

RUN git clone -b ${REDISJSON_VERSION} --recursive  https://github.com/RedisJSON/RedisJSON.git RedisJSON && \
    cd RedisJSON && git submodule update --recursive --init
RUN RedisJSON/deps/readies/bin/system-setup.py
RUN cd RedisJSON && make setup && make build

#----------------------------------------------------------------------------------------------
# Build Redis Bloom Module for KeyDB

# RUN git clone -b ${REDISJSON_VERSION} --recursive  https://github.com/RedisBloom/RedisBloom.git RedisBloom && \
#     cd RedisBloom && git submodule update --recursive --init
# RUN cd RedisBloom && set -ex && make clean && make all -j 4

#----------------------------------------------------------------------------------------------
# Build Redis Graph Module for KeyDB

# RUN git clone -b ${REDISJSON_VERSION} --recursive  https://github.com/RedisGraph/RedisGraph.git RedisGraph && \
#     cd RedisGraph && git submodule update --recursive --init
# RUN cd RedisGraph && make

#----------------------------------------------------------------------------------------------
# Build Redis Timeseries Module for KeyDB

# RUN git clone -b ${REDISJSON_VERSION} --recursive  https://github.com/RedisTimeSeries/RedisTimeSeries.git RedisTimeSeries && \
#     cd RedisTimeSeries && git submodule update --recursive --init
# RUN RedisTimeSeries/deps/readies/bin/system-setup.py
# RUN cd RedisTimeSeries && make build

#----------------------------------------------------------------------------------------------
# Configure and start KeyDB Image with Redis Modules

FROM eqalpha/keydb:${KEY_DB_VERSION} AS prod
ADD keydb.conf /etc/keydb.conf

# ADD /deps/glibc-2.29.tar.gz ./glibc-2.29.tar.gz
# RUN chmod +x glibc-2.29.tar.gz
# RUN tar -zxvf glibc-2.29.tar.gz
# RUN cd glibc-2.29
# RUN configure --prefix=/opt/glibc
# RUN make
# RUN make install

COPY --from=builder /keydb/RediSearch/bin/linux-x64-release/search/redisearch.so /etc/libs/redisearch.so
COPY --from=builder /keydb/RedisJSON/bin/linux-x64-release/search/rejson.so /etc/libs/rejson.so

EXPOSE 6379
CMD ["keydb-server", "/etc/keydb.conf"]
