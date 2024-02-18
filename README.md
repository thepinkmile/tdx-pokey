# tdx-pokey
Toradex Docker Image Creator

## build
docker build --no-cache -t tdx-base -f Dockerfile ./context

## usage
docker run --rm -v ./sstate_cache:/opt/yocto-state -v ./output:/opt/yocto-output --entrypoint /bin/bash -it tdx-base