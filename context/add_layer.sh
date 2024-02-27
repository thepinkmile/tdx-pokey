#!/bin/bash
set -e

script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
config_directory=${working_directory}/build/conf
echo "Script directory: ${script_path}"
echo "Running in: ${working_directory}"

layer_name=meta-demo-layer
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            shift
            layer_name=$1
            ;;
        --help)
            echo "###########################################"
            echo "### Toradex yocto layer addition script ###"
            echo "###########################################"
            echo ""
            echo "./add_layer.sh [--name {layer-namae}]"
            echo ""
            echo "--name: Required, The name of the layer to include (folder must already exist in the current working 'layers' direcotry)."
            echo ""
            echo "###########################################"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

if ! [ -f ${config_directory}/bblayers.conf ]; then
    pushd ${working_directory}
        source export
    popd
fi

if ! grep -q "${layer_name}" "${config_directory}/bblayers.conf"; then
    echo "BBLAYERS += \"\${TOPDIR}/../layers/${layer_name}\"" >> ${config_directory}/bblayers.conf
fi
