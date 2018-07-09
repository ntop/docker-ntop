# ntop Dockerfiles

This repository contains configuration files used to generate Docker images registered on Dockerhub.


# PF_RING

## Install and Run

```
docker build -t pfring -f Dockerfile.pfring .
docker run --net=host pfring pfcount -i eth0
```

For additional info please read the [PF_RING User's Guide](http://www.ntop.org/guides/pf_ring/containers/docker.html)
