# tdx-pokey
Toradex Docker Image Creator

## build
docker build --no-cache -t tdx-base -f Dockerfile ./context

## usage
docker run --rm --privileged --name tdx-builder -v ./sstate_cache:/opt/yocto-state -v ./output:/opt/yocto-output --entrypoint /bin/bash -it tdx-base

## copy output from container (while it is running)
docker cp tdx-builder:/opt/yocto-output/yocto-state.tar.gz ./
docker cp tdx-builder:/opt/yocto-output/verdin-image.tar.gz ./
