# ntop Dockerfiles

This repository contains configuration files used to generate Docker images registered on Dockerhub.

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

For additional info please read the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/containers/docker.html)
