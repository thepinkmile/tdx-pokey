#!/bin/bash
set -e

script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
config_directory=${working_directory}/build/conf
artifacts_directory=${script_path}/../artifacts

secure_boot=$false
num_threads=4
while [[ $# -gt 0 ]]; do
    case $1 in
        --secure-boot)
            echo "Enabling Secure-Boot"
            secure_boot=$true
            ;;
        --threads)
            echo "Setting thread count to: ${num_threads}"
            shift
            num_threads=$1
            ;;
        --help)
            echo "########################################"
            echo "### Toradex environment setup script ###"
            echo "########################################"
            echo ""
            echo "./prepare.sh [--secure-boot] [--threads {n}]"
            echo ""
            echo "--secure-boot: Requires the imx cst tool to be available in '${artifacts_directory}'. This will enable the toradex-security yocto layer and generate required certificates."
            echo "--threads: Default=4, This is used to limit the executing threads (which is useful for constrained environments like docker containers."
            echo ""
            echo "########################################"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
    shift
done

echo "Running in: ${working_directory}"
echo "Script directory: ${script_path}"
echo "Config directory: ${config_directory}"

if ! [ -d ${artifacts_directory} ]; then
    mkdir ${artifacts_directory}
fi

source export

if [[ secure_boot -eq $true ]]; then
    pushd ${working_directory}
        ${script_path}/add_layer.sh --repo-root https://github.com/toradex --repo-name meta-toradex-security --repo-branch kirkstone-6.x.y
    popd
    
    cst_install_dir=/opt/tools/cst
    cst_crts_root=${working_directory}/cst
    
    tar -xzvf /opt/tools/IMX_CST_TOOL_NEW.tgz -C /opt/tools
    mv /opt/tools/cst* ${cst_install_dir}
    
    # generate signing certificates
    cert_key_type="rsa"
    cert_key_length=4096
    cert_key_digest="sha256"
    cert_duration_years=10
    if ! [ -d ${cst_crts_root} ]; then
        mkdir ${cst_crts_root}
    fi
    if [ -f ${artifacts_directory}/cst.tar.gz ]; then
        tar -xzvf ${artifacts_directory}/cst.tar.gz -C ${working_directory}
        rm -f ${artifacts_directory}/cst.tar.gz
    fi
    if ! [ -d ${cst_crts_root}/keys ]; then
        pushd ${cst_install_dir}/keys
            cert_serial="1928374650"
            cert_pass="Crt_Pass1234"
            
            echo "${cert_serial}" > serial
            echo "${cert_pass}" > key_pass.txt
            echo "${cert_pass}" >> key_pass.txt
            
            ./hab4_pki_tree.sh -existing-ca n -kt ${cert_key_type} -kl ${cert_key_length} -duration ${cert_duration_years} -num-srk 4 -srk-ca y
            
            pushd ../crts
                ../linux64/bin/srktool -h 4 -t SRK_1_2_3_4_table.bin -e SRK_1_2_3_4_fuse.bin -d ${cert_key_digest} -f 1 -c SRK1_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem,SRK2_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem,SRK3_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem,SRK4_${cert_key_digest}_${cert_key_length}_65537_v3_ca_crt.pem
            popd
            
            mkdir ${cst_crts_root}/keys
            mkdir ${cst_crts_root}/crts
            
            cp ../crts/* ${cst_crts_root}/crts
            cp * ${cst_crts_root}/keys
            cd ${cst_crts_root}/keys && rm -f *.sh
            cd ${cst_crts_root}/keys && rm -f *.bat
            cd ${cst_crts_root}/keys && rm -f *.exe
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
fi

# change the config
sed -i 's@#MACHINE ?= "verdin-imx8mp"@MACHINE ?= "verdin-imx8mp"\nACCEPT_FSL_EULA = "1"\n@g' ${config_directory}/local.conf
sed -i 's@PACKAGE_CLASSES ?= "package_ipk"@PACKAGE_CLASSES ?= "package_deb"@g' ${config_directory}/local.conf
sed -i 's@SSTATE_DIR ?= "${TOPDIR}/../sstate-cache"@SSTATE_DIR ?= "/opt/yocto-state"@g' ${config_directory}/local.conf

#if ! grep -q "UBOOT_CONFIG" "${config_directory}/local.conf"; then
#    echo "UBOOT_CONFIG = \"emmc\"" >> ${config_directory}/local.conf
#fi

if ! grep -q "BB_NUMBER_THREADS" "${config_directory}/local.conf"; then
    echo "BB_NUMBER_THREADS = \"${num_threads}\"" >> ${config_directory}/local.conf
fi

if ! grep -q "PARALLEL_MAKE" "${config_directory}/local.conf"; then
    echo "PARALLEL_MAKE = \"-j ${num_threads}\"" >> ${config_directory}/local.conf
fi
