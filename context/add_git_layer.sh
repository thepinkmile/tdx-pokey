#!/bin/bash
set -e

script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
working_directory=$PWD
config_directory=${working_directory}/build/conf
echo "Script directory: ${script_path}"
echo "Running in: ${working_directory}"

meta_repo_name=meta-mmg-custom
meta_repo_path=https://github.com/thepinkmile
meta_repo_branch=main
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo-root)
            shift
            meta_repo_path=$1
            ;;
        --repo-name)
            shift
            meta_repo_name=$1
            ;;
        --repo-branch)
            shift
            meta_repo_branch=$1
            ;;
        --help)
            echo "###########################################"
            echo "### Toradex yocto layer addition script ###"
            echo "###########################################"
            echo ""
            echo "./add_layer.sh [--repo-root {git-base-url}] [--repo-name {layer-namae}] [--repo-branch {branch-or-commit}]"
            echo ""
            echo "--repo-root: Required, The base url for your git repository source (default layer example is for personal learning only)."
            echo "--repo-name: Required, The name of the git repository (which should be the same as the layer name)."
            echo "--repo-branch: Default=main, The name of the git repository branch to be cloned."
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
echo "Git Repo Path: ${meta_repo_path}"
echo "Git Repo Name: ${meta_repo_name}"
echo "Git Repo Branch: ${meta_repo_branch}"

if ! [ -d ${working_directory}/layers/${meta_repo_name} ]; then
    echo "Retrieving meta layer ${meta_repo_name}..."
    git clone -b ${meta_repo_branch} ${meta_repo_path}/${meta_repo_name}.git ${working_directory}/layers/${meta_repo_name}
else
    pushd ${working_directory}/layers/${meta_repo_name}
        echo "Updating meta layer ${meta_repo_name}..."
        git pull
    popd
fi

pushd ${working_directory}
    ${script_path}/add_layer.sh --name ${meta_repo_name}
popd
