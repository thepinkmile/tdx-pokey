# tdx-pokey
Toradex Docker Image Creator.

## build
To build the main docker image use the provided batch script:
```
./build_docker.bat
```

## usage
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

## copy output from container (while it is running)
Now copy the resulting output from the container (from another cmd/poershell prompt) before exiting the intreractive shell:
```
./get_yocto_state.bat
```
