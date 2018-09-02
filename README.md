# ntop Dockerfiles

This repository contains configuration files used to generate Docker images registered on [Dockerhub](https://hub.docker.com/u/ntop).

## Prerequisites

In order to use the PF_RING tools or take advantage of the PF_RING acceleration when using the ntop
applications, the PF_RING kernel module and drivers need to be loaded on the host system. Please 
read the instructions in the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/get_started/index.html)

# PF_RING Tools

## Install and Run

```
docker build -t pfring -f Dockerfile.pfring .
docker run --net=host pfring pfcount -i eth0
```

If you want to use a ZC interface, you need to access the license file from the container, 
you can use the -v|--volume option for this:

```
docker run --net=host -v 001122334455:/etc/pf_ring/001122334455 pfring pfcount -i zc:eth1
```

For additional info please read the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/containers/docker.html)

# ntopng

## Install and Run

```
docker build -t ntopng -f Dockerfile.ntopng .
docker run -it --net=host -p 3000:3000 ntopng -i eth0
```

# nProbe

## Install and Run

```
docker build -t nprobe -f Dockerfile.nprobe .
docker run -it --net=host nprobe -i eth0
```

# n2disk

## Install and Run

```
docker build -t n2disk -f Dockerfile.n2disk .
docker run -it --net=host n2disk -i eth0 -o /tmp
```

# nscrub

## Install and Run

```
docker build -t nscrub -f Dockerfile.nscrub .
docker run -it --net=host -p 8880:8880 nscrub -i eth1 -o eth2
```

Note: you can configure the application license sharing the license file with the container, 
you can do this using the -v|--volume option. This applies to all the applications.

```
docker run -it --net=host -p 8880:8880 -v $(pwd)/nscrub.license:/etc/nscrub.license nscrub -i eth1 -o eth2
```

