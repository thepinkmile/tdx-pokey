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

if ! [ -d ${working_directory}/layers/meta-toradex-security ]; then
    git clone -b kirkstone-6.x.y https://github.com/toradex/meta-toradex-security.git ${working_directory}/layers/meta-toradex-security
	pushd ${working_directory}/layers/meta-toradex-security
		# checkout the known hash as in torizoncore manifest
	    git checkout fc9238ab2790a55d9f88f76e672c47567d2cfadb
	popd
fi
if ! grep -q "meta-toradex-security" "${config_directory}/bblayers.conf"; then
    echo 'BBLAYERS += "${TOPDIR}/../layers/meta-toradex-security"' >> ${config_directory}/bblayers.conf
fi

# change the config
sed -i 's@#MACHINE ?= "verdin-imx8mp"@MACHINE ?= "verdin-imx8mp"\nACCEPT_FSL_EULA = "1"\n@g' ${config_directory}/local.conf
sed -i 's@SSTATE_DIR ?= "${TOPDIR}/../sstate-cache"@SSTATE_DIR ?= "/opt/yocto-state"@g' ${config_directory}/local.conf
sed -i 's@PACKAGE_CLASSES ?= "package_ipk"@PACKAGE_CLASSES ?= "package_deb"@g' ${config_directory}/local.conf

if ! [ -d ${cst_crts_root} ]; then
	pushd ${cst_install_dir}/keys
		cert_serial="1928374650"
		cert_pass="Crt_Pass1234"
		cert_key_type="rsa"
		cert_key_length=4096
		cert_key_digest="sha256"
		cert_duration_years=10
		
		echo "${cert_serial}" > serial
		echo "${cert_pass}" > key_pass.txt
		echo "${cert_pass}" >> key_pass.txt
		
		./hab4_pki_tree.sh -existing-ca n -kt ${cert_key_type} -kl ${cert_key_length} -duration ${cert_duration_years} -num-srk 4 -srk-ca y
		
		pushd ../crts
			../linux64/bin/srktool -h 4 -t SRK_1_2_3_4_table.bin -e SRK_1_2_3_4_fuse.bin -d ${cert_key_digest} -f 1 -c SRK1_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem,SRK2_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem,SRK3_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem,SRK4_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem
		popd
		
			mkdir ${cst_crts_root}
			mkdir ${cst_crts_root}/keys
			mkdir ${cst_crts_root}/crts
		
		cp *.pem ${cst_crts_root}/keys
		cp *.der ${cst_crts_root}/keys
		cp serial* ${cst_crts_root}/keys
		cp index.* ${cst_crts_root}/keys
		cp key_pass.txt ${cst_crts_root}/keys
		cp ../crts/*.pem ${cst_crts_root}/crts
		cp ../crts/*.der ${cst_crts_root}/crts
		cp ../crts/SRK_1_2_3_4_*.bin ${cst_crts_root}/crts
	popd
fi
if ! grep -q "tdx-signed" "${config_directory}/local.conf"; then
	echo "INHERIT += \"tdx-signed\"" >> ${config_directory}/local.conf
fi
if ! grep -q "TDX_IMX_HAB_ENABLE" "${config_directory}/local.conf"; then
	echo "TDX_IMX_HAB_ENABLE = \"1\"" >> ${config_directory}/local.conf
fi
if ! grep -q "UBOOT_SIGN_ENABLE" "${config_directory}/local.conf"; then
	echo "UBOOT_SIGN_ENABLE = \"1\"" >> ${config_directory}/local.conf
fi
if ! grep -q "TDX_IMX_HAB_CST_DIR" "${config_directory}/local.conf"; then
	echo "TDX_IMX_HAB_CST_DIR = \"${cst_install_dir}\"" >> ${config_directory}/local.conf
fi
if ! grep -q "TDX_IMX_HAB_CST_CERTs_DIR" "${config_directory}/local.conf"; then
	echo "TDX_IMX_HAB_CST_CERTS_DIR = \"${cst_crts_root}/crts\"" >> ${config_directory}/local.conf
fi
if ! grep -q "TDX_IMX_HAB_CST_KEY_SIZE" "${config_directory}/local.conf"; then
	echo "TDX_IMX_HAB_CST_KEY_SIZE = \"${cert_key_length}\"" >> ${config_directory}/local.conf
fi
if ! grep -q "TDX_IMX_HAB_CST_CRYPTO" "${config_directory}/local.conf"; then
	echo "TDX_IMX_HAB_CST_CRYPTO = \"${cert_key_type}\"" >> ${config_directory}/local.conf
fi
if ! grep -q "TDX_IMX_HAB_CST_DIG_ALGO" "${config_directory}/local.conf"; then
	echo "TDX_IMX_HAB_CST_DIG_ALGO = \"${cert_key_digest}\"" >> ${config_directory}/local.conf
fi

#if ! grep -q "UBOOT_CONFIG" "${config_directory}/local.conf"; then
#	echo "UBOOT_CONFIG = \"emmc\"" >> ${config_directory}/local.conf
#fi
