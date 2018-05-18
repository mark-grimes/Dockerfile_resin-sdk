# resin-sdk

Image to cross compile code for resin-os. Includes docker so that container images can be created
from build result.

Includes a cross compile compatible version of ldd from
https://gist.github.com/jerome-pouiller/c403786c1394f53f44a3b61214489e6f to figure out what libraries
should be in an image. This version is at `/bin/xldd` and should be executed with the sysroot as an
argument, i.e. `xldd --root /opt/resin-os/2.4.1/sysroots/arm1176jzfshf-vfp-poky-linux-gnueabi`.

Also useful (but not included) is the
[extractDynamicLibs.sh](https://github.com/mark-grimes/Dockerfiles/blob/master/extractDynamicLibs.sh)
script which can pull out those libraries into a single directory for addition to the docker image.

## Usage

Start a container and you will have a shell. Before doing anything else you will need to source the
environment script:

```
source /opt/resin-os/2.4.1/environment-setup-arm1176jzfshf-vfp-poky-linux-gnueabi
```

You should then have CMake available, and the correct compiler commands stored in the $CC and $CXX
variables. When using CMake, it automatically uses the compiler referenced in those variables.

## Build

The .sh script in the repository was built using the Resin OS image creation system (see
https://resinos.io/docs/custombuild/) using commands similar to below.

```
docker run --rm -it -v yocto:/build --privileged yocto-build-env

docker daemon 2> /dev/null &
chown -R builder:builder /build/
su builder
cd /build
git clone https://github.com/resin-os/resin-raspberrypi
cd resin-raspberrypi
git submodule update --init --recursive
./resin-yocto-scripts/build/barys -n -r --shared-downloads $(pwd)/shared-downloads/ --shared-sstate $(pwd)/shared-sstate/ -m raspberrypi
source /build/resin-raspberrypi/layers/poky/oe-init-build-env /build/resin-raspberrypi/build
MACHINE=raspberrypi DISTRO=resin-systemd bitbake resin-image -c populate_sdk
```

The build result will then be in `/data/resin-raspberrypi/build/tmp/deploy/sdk/`.

Note that you will need around 100Gb available to docker, and I had to increase the memory and swap
limits to fix a linking step failure (works with 7Gb memory, 3Gb swap; maybe less).
