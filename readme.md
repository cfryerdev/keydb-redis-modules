# KeyDB Redis Stack

My KeyDB Docker image with multiple Redis Modules installed.

## Using image

You can find the image on dockerhub: [Keydb-Redis-Stack](https://hub.docker.com/repository/docker/cfryerdev/keydb-redis-stack)

## Redis Modules

- RediSearch v2.6.15
- RedisJSON (WIP)
- RedisBloom (WIP)
- RedisGraph (WIP)
- RedisTimeSeries (WIP)

## Building Image

Simply run to build it.
```bash
docker build . -t cfryerdev/keydb-redis-stack
```

## Upgrading Image

Inside the dockerfile are various variables you can change to customize the version of KeyDB as well as each Redis Module.