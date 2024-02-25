# tdx-pokey
Toradex Docker Image Creator.

This is for building the Toradex custom images for the imx8mp verdin development board.
It is used for my personal learning of how yocto projects work while I have a verdin dev board available to play with.

## Aims
NOTE: This process will require 2 powershell (or cmd prompt) instances to be available (due to how docker containers work).

The main aims of this repo are:
1. To see if it is possible to build the required images on a Windows machine (using WSL2 and docker).
2. To understand how to build a secure-boot image.
3. To understand how to build an image with full-disk encryption
4. To learn how to create custom yocto layers, distributions and images

## Building the docker build environment
To build the main docker image use the provided batch script:
```
./build_docker.bat
```

## Using the docker build environment
Start a new container (named tdx-builder in these examples):
```
docker run --rm --privileged --name tdx-builder --entrypoint /bin/bash -it tdx-base
```
Then (if required) copy any previous state into the container in another cmd/powershell prompt:
```
./set_yocto_state.bat
```
Then execute the build script from the container shell:
```
../tools/build.sh
```

## Retrieve output from the docker environment
Now copy the resulting output from the container (from another cmd/poershell prompt) before exiting the intreractive shell:
```
./get_yocto_state.bat
```
