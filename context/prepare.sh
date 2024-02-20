#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
config_directory=${working_directory}/build/conf

echo "Running in: ${working_directory}"
echo "Script directory: ${path}"
echo "Config directory: ${config_directory}"

source export

if ! [ -d layers/meta-toradex-security ]; then
    git clone -b kirkstone-6.x.y https://github.com/toradex/meta-toradex-security.git layers/meta-toradex-security
fi
if ! grep -q "meta-toradex-security" "${config_directory}/bblayers.conf"; then
    echo 'BBLAYERS += "${TOPDIR}/../layers/meta-toradex-security"' >> ${config_directory}/bblayers.conf
fi

# change the config
sed -i 's@#MACHINE ?= "verdin-imx8mp"@MACHINE ?= "verdin-imx8mp"\nACCEPT_FSL_EULA = "1"\nINHERTT += "tdx-signed"\n@g' ${config_directory}/local.conf
sed -i 's@SSTATE_DIR ?= "${TOPDIR}/../sstate-cache"@SSTATE_DIR ?= "/opt/yocto-state"@g' ${config_directory}/local.conf
sed -i 's@PACKAGE_CLASSES ?= "package_ipk"@PACKAGE_CLASSES ?= "package_deb"@g' ${config_directory}/local.conf
