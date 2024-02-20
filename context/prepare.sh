#!/bin/bash
set -e

path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
config_directory=${working_directory}/build/conf
cst_install_dir=/opt/tools/cst-3.4.0
cst_crts_root=${working_directory}/cst

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

pushd ${cst_install_dir}/keys
    echo "1928374650" > serial
    echo "Crt_Pass1234" > key_pass.txt
    echo "Crt_Pass1234" >> key_pass.txt
    
    ./ahab_pki_tree.sh -existing-ca n -kt rsa -kl 4096 -da sha256 -duration 10 -srk-ca y
    
    pushd ../crts
        ../linux64/bin/srktool -a -t SRK_1_2_3_4_table.bin -e SRK_1_2_3_4_fuse.bin -s sha256 -f 1 -c SRK1_sha256_4096_65537_v3_ca_crt.pem,SRK2_sha256_4096_65537_v3_ca_crt.pem,SRK3_sha256_4096_65537_v3_ca_crt.pem,SRK4_sha256_4096_65537_v3_ca_crt.pem
    popd
    
    if ! [ -d ${cst_crts_root} ]; then
        mkdir ${cst_crts_root}
        mkdir ${cst_crts_root}/keys
        mkdir ${cst_crts_root}/crts
    fi
	
    cp *.pem ${cst_crts_root}/keys
    cp ../crts/*.pem ${cst_crts_root}/crts
	cp ../crts/SRK_1_2_3_4_*.bin ${cst_crts_root}/crts
	
	if ! grep -q "TDX_IMX_HAB_CST_DIR" "${config_directory}/local.conf"; then
	    echo 'TDX_IMX_HAB_CST_DIR="${cst_install_dir}/linux64/bin"' >> ${config_directory}/local.conf
	fi
	if ! grep -q "TDX_IMX_HAB_CST_CERTS_DIR" "${config_directory}/local.conf"; then
		echo 'TDX_IMX_HAB_CST_CERTS_DIR="${cst_crts_root}/crts"' >> ${config_directory}/local.conf
	fi
	if ! grep -q "TDX_IMX_HAB_CST_KEY_SIZE" "${config_directory}/local.conf"; then
		echo 'TDX_IMX_HAB_CST_KEY_SIZE=4096' >> ${config_directory}/local.conf
	fi
	if ! grep -q "TDX_IMX_HAB_CST_CRYPTO" "${config_directory}/local.conf"; then
		echo 'TDX_IMX_HAB_CST_CRYPTO="rsa"' >> ${config_directory}/local.conf
	fi
	if ! grep -q "TDX_IMX_HAB_CST_DIG_ALGO" "${config_directory}/local.conf"; then
		echo 'TDX_IMX_HAB_CST_DIG_ALGO="sha256"' >> ${config_directory}/local.conf
	fi
	if ! grep -q "TDX_IMX_HAB_CST_SRK_CA" "${config_directory}/local.conf"; then
		echo 'TDX_IMX_HAB_CST_SRK_CA=1' >> ${config_directory}/local.conf
	fi
	if ! grep -q "TDX_IMX_HAB_ENABLE" "${config_directory}/local.conf"; then
		echo 'TDX_IMX_HAB_ENABLE=1' >> ${config_directory}/local.conf
	fi
popd
