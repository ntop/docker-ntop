FROM ubuntu:18.04
MAINTAINER ntop.org

RUN apt-get update && \
    apt-get -y -q install software-properties-common wget lsb-release gnupg

RUN wget -q http://apt.ntop.org/18.04/all/apt-ntop.deb && \
    dpkg -i apt-ntop.deb && \
    apt-get clean all

RUN apt-get update && \
    apt-get -y install nprobe-agent

RUN echo '#!/bin/bash\nnprobe-agent "$@"' > /run.sh && \
    chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
