#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "Script directory: ${path}"
working_directory=$PWD
echo "Running in: ${working_directory}"

meta_repo_name=meta-mmg-custom
meta_repo_path=https://github.com/thepinkmile
meta_repo_branch=master

source export

if [ -d ${working_directory}/layers/${meta_repo_name} ]; then
    git clone -b ${meta_repo_branch} ${meta_repo_path}/${meta_repo_name}.git ${working_directory}/layers/${meta_repo_name}
    
    if ! grep -q "${meta_repo_name}" "${config_directory}/bblayers.conf"; then
        echo "BBLAYERS += \"\${TOPDIR}/../layers/${meta_repo_name}\"" >> ${config_directory}/bblayers.conf
    fi
fi
