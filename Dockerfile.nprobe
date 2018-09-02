FROM ubuntu:18.04
MAINTAINER ntop.org

RUN apt-get update && \
    apt-get -y -q install wget lsb-release gnupg && \
    wget -q http://apt-stable.ntop.org/16.04/all/apt-ntop-stable.deb && \
    dpkg -i apt-ntop-stable.deb && \
    apt-get clean all

RUN apt-get update && \
    apt-get -y install nprobe 

RUN echo '#!/bin/bash\nnprobe "$@"' > /run.sh && \
    chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
