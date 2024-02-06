# KeyDB Redis Stack

My KeyDB Docker image with multiple Redis Modules installed.

KeyDB Version: **v6.3.4**

## Using image

You can find the image on dockerhub: [Keydb-Redis-Stack](https://hub.docker.com/repository/docker/cfryerdev/keydb-redis-stack)

## Redis Modules

Below are the redis modules supported or have planned support:

|Module|Version|
|---|-----------|
| RediSearch | v2.6.15 |
| RedisJSON | v2.6.4 |
| RedisBloom | WIP |
| RedisGraph | WIP |
| RedisTimeSeries | WIP |

## Building Image

Simply run to build it.
```bash
docker build . -t cfryerdev/keydb-redis-stack
```

## Enable/Disable modules

If you want to turn a specific module off, please change the `keydb.conf` file before building the image or change it within the image after building. It will be located in: `/etc/keydb.conf`

## Upgrading Image

Inside the dockerfile are various variables you can change to customize the version of KeyDB as well as each Redis Module.