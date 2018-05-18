FROM debian:stretch

RUN apt-get update \
    && apt-get install -y curl git build-essential python \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL get.docker.com -o get-docker.sh \
    && chmod u+x get-docker.sh \
    && CHANNEL="stable" ./get-docker.sh \
    && rm ./get-docker.sh

ADD resin-os-glibc-x86_64-resin-image-arm1176jzfshf-vfp-toolchain-2.4.1.sh /install.sh
RUN chmod u+x /install.sh \
    && /install.sh \
    && rm /install.sh

# Get the cross-toolchain compatible version of ldd to figure out which libraries
# need to be in a docker image.
RUN curl -fsSL https://gist.github.com/jerome-pouiller/c403786c1394f53f44a3b61214489e6f/raw/eb44581caf7dd60b149a6691abef46264c46e866/cross-compile-ldd \
    | sed s:"\${prefix}-gcc":"arm-poky-linux-gnueabi-gcc": \
    | sed s:"\${prefix}-readelf":"readelf": > /bin/xldd \
    && chmod ugo+x /bin/xldd
