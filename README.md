# ntop Dockerfiles

This repository contains configuration files used to generate Docker images registered on [Dockerhub](https://hub.docker.com/u/ntop).

## Prerequisites

In order to use the PF_RING tools or take advantage of the PF_RING acceleration when using the ntop
applications, the PF_RING kernel module and drivers need to be loaded on the host system. Please
read the instructions in the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/get_started/index.html)
and [Using PF_RING with Docker](https://www.ntop.org/guides/pf_ring/containers/docker.html)

## License Note

Commercial ntop tools require a license which is based on a system identifier which is computed on locally attached network interfaces and other hardware components. If you want to use within all the Docker containers the same license generated for the host OS, the containers must use [host networking](https://docs.docker.com/network/host/). For docker-compose, see the [Compose file reference](https://docs.docker.com/compose/compose-file/compose-file-v3/#network_mode).

# Docker Compose
The following is an example `compose.yml` file to create containers for nTopNG, an nProbe collector, and a ClickHouse server for [historic flows](https://www.ntop.org/guides/ntopng/clickhouse.html) (included with Enterprise L or better).  You can avoid having to use host networking with all containers by generating a speficic license file for each commercial ntop tool.
Example `compose.yml` file:
```
version: "3.9"
services:
  nprobe_collector:
    image: ntop/nprobe:stable
    restart: always
    network_mode: "host"
    volumes:
      - /etc/nprobe.license:/etc/nprobe.license:ro
    command: ['nprobe', '--zmq', '"tcp://ntopng:5556"', '--interface', 'none', '-n', 'none', '--collector-port', '2055', '-T', '"@NTOPNG@"', '--collector-passthrough']

  ntopng:
    image: ntop/ntopng:latest
    restart: always
    network_mode: "host"
    volumes:
      - /etc/ntopng.license:/etc/ntopng.license:ro
    command: ['--disable-login', '--interface', 'tcp://*:5556c', '-F', 'clickhouse'] # , '--insecure']
    depends_on:
      - clickhouse
      - nprobe_collector
      
  clickhouse:
    image: clickhouse/clickhouse-server:latest
    network_mode: "host"
    restart: always
    volumes:
      - clickhouse_data:/var/lib/clickhouse
      - clickhouse_logs:/var/log/clickhouse-server/
      
volumes:
  clickhouse_data:
  clickhouse_logs:

```

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
