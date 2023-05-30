#!/usr/bin/env bash

set -e
set -o pipefail


logger() {
    local _msg="$1"
    local _fail_cond="${2:-0}"
    if ((_fail_cond)); then 
        echo -e "[FAILED] $(date) >> $_msg"
        exit 1
    else
        echo -e "[LOG] $(date) >> $_msg"
    fi
}

set_workdir(){
    local _workdir
    _workdir="$1"
    mkdir -p "$_workdir"
    cd "$_workdir"
}

check_download_tool() {
    if which curl 1>/dev/null; then
        _DOWNLOAD_TOOL = "curl"
        logger "curl is installed"
        return 0
    elif which wget 1>/dev/null; then
        _DOWNLOAD_TOOL = "wget"
        logger "wget is installed"
        return 0
    else
        logger "installing curl"
        apt update -y && apt install curl -y
        return 0
    fi
    logger "Curl could not be installed" "1"
}

get_awl_cli_url(){
    local _version
    local _architecture
    local _aws_cli_url=""

    _version="$1"
    _architecture="$2"

    if [[ "$_version" =~ ^2.*$ ]] ; then
        if [[ "$_architecture" = "amd64" ]] ; then
            _architectue = "x86_64"
        elif [[ "$_version" = "arm64" ]] ; then
            _architecture = "aarch64"
        fi

        if [[ "$_version" = 2 ]] ; then
            _aws_cli_url = "https://awscli.amazonaws.com/awscli-exe-linux-${_architecture}.zip"
        else
            _aws_cli_url = "https://awscli.amazonaws.com/awscli-exe-linux-${_architecture}-${_version}.zip"
        fi
    fi
    
    echo "$_aws_cli_url"
}

download_aws_cli(){
    
}

# DEFAULT VALUES
_DEAFULT_ARCH="amd64"
_DEFAULT_VERSION="2"

# GLOBAL VARIABLES
_AWS_CLI_VERSION="${1:-"$AWS_CLI_VERSION"}"
_AWS_CLI_VERSION="${_AWS_CLI_VERSION:-"$_DEFAULT_VERSION"}"

_AWS_CLI_ARCH="${2:-"$AWS_CLI_ARCH"}"
_AWS_CLI_ARCH="${_AWS_CLI_ARCH,,}"
_AWS_CLI_ARCH="${_AWS_CLI_ARCH:-"$_DEAFULT_ARCH"}"

_WORKDIR="$PWD/awscli"

set_workdir "$_WORKDIR"
