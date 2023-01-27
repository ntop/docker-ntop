# ntop Dockerfiles

This repository contains configuration files used to generate Docker images registered on [Dockerhub](https://hub.docker.com/u/ntop).

Ntop license generation and verification uses the names and number of all locally attached network interfaces. If the license used within the Docker is the same as the one used on the host OS, the containers must [use host networking](https://docs.docker.com/network/host/). For docker-compose, see the [Compose file reference](https://docs.docker.com/compose/compose-file/compose-file-v3/#network_mode).


## Prerequisites

In order to use the PF_RING tools or take advantage of the PF_RING acceleration when using the ntop
applications, the PF_RING kernel module and drivers need to be loaded on the host system. Please
read the instructions in the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/get_started/index.html)
and [Using PF_RING with Docker](https://www.ntop.org/guides/pf_ring/containers/docker.html)

# PF_RING Tools

## Install and Run

```bash
docker build -t pfring -f Dockerfile.pfring .
docker run --net=host pfring pfcount -i eno1
```

If you want to use a ZC interface, you need to access the license file from the container,
you can use the -v|--volume option for this:

```bash
docker run --net=host -v 001122334455:/etc/pf_ring/001122334455 pfring pfcount -i zc:eth1
```

For additional info please read the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/containers/docker.html)

# ntopng

## Install and Run

```bash
docker build -t ntopng -f Dockerfile.ntopng .
docker run -it --net=host ntopng -i eno1
```

### Docker Compose
Example `compose.yml` file:
```
version: "3.9"
services:
  ntopng:
    image: ntop/ntopng:latest
    restart: always
    network_mode: "host"
    volumes:
      - /etc/ntopng.license:/etc/ntopng.license
    command: ['--interface', 'tcp://*:5556c']
    command: ['--interface', 'eth0']
```

# nProbe

## Install and Run

```bash
docker build -t nprobe -f Dockerfile.nprobe .
docker run -it --net=host nprobe -i eno1
```

# nTap

## Install and Run

```bash
docker build -t nprobe -f Dockerfile.ntap.dev .
docker run -it --net=host ntap -i eth0 -c <ntap_collector_ip>:1234 -k my_pwd
```
# nProbe Cento

## Install and Run

```bash
docker build -t cento -f Dockerfile.cento .
docker run -it --net=host cento -i eno1
```

# n2disk

## Install and Run

```bash
docker build -t n2disk -f Dockerfile.n2disk .
docker run -it --cap-add IPC_LOCK --net=host n2disk -i eno1 -o /tmp
```

Note: IPC_LOCK is required to use the Direct IO support in n2disk, which required mlock.

# nScrub

## Install and Run

```bash
docker build -t nscrub -f Dockerfile.nscrub .
docker run -it --net=host nscrub -i eth1 -o eth2
```

Note: you can configure the application license sharing the license file with the container,
you can do this using the -v|--volume option. This applies to all the applications.

```bash
docker run -it --net=host -v $(pwd)/nscrub.license:/etc/nscrub.license nscrub -i eth1 -o eth2
```

# `NTOP_CONFIG` environment variable

You can pass configuration options also via the `NTOP_CONFIG` environment variable, using the `-e` option. This applies to all the applications.

```bash
docker run -it -e NTOP_CONFIG="-i eno1" --net=host ntopng
```
