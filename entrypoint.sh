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
        _DOWNLOAD_TOOL="curl"
        logger "curl is installed"
    elif which wget 1>/dev/null; then
        _DOWNLOAD_TOOL="wget"
        logger "wget is installed"
    else
        logger "not download tool could be found" "1"
    fi
}

get_aws_cli_url(){
    local _version
    local _architecture
    local _cli_url=""

    _version="$1"
    _architecture="$2"

    if [[ "$_version" =~ ^2.*$ ]] ; then
        if [[ "$_architecture" = "amd64" ]] ; then
            _architecture="x86_64"
        elif [[ "$_architecture" = "arm64" ]] ; then
            _architecture="aarch64"
        fi


        if [[ "$_version" = 2 ]] ; then
            _cli_url="https://awscli.amazonaws.com/awscli-exe-linux-${_architecture}.zip"
        else
            _cli_url="https://awscli.amazonaws.com/awscli-exe-linux-${_architecture}-${_version}.zip"
        fi
    fi
    
    echo "$_cli_url"
}

download_aws_cli(){
    local _cli_url
    local _output_file
    _cli_url="$1"
    _output_file="$2"

    if [[ "$_DOWNLOAD_TOOL" = "curl" ]]; then
        curl -sL -o "$_output_file" "$_cli_url"
    elif [[ "$_DOWNLOAD_TOOL" = "wget" ]]; then
        wget -q -O "$_output_file" "$_cli_url"
    fi

    ls -lah "$_output_file"

    logger "AWS installer downloaded"
    wait
}

install_aws_cli(){
    local _installer_filename
    local _version
    local _architecture

    _installer_filename="$1"
    _version="$2"
    _architecture="$3"

    if ! [[ -e ${_installer_filename} ]]; then
        logger "installer does not exists" "1"
    fi
    
    logger "Unzipping ${_installer_filename}"
    unzip -qqu "$_installer_filename"

    wait

    logger "Installing AWS CLI"
    if [[ "$_version" =~ ^2.*$ ]]; then
        local aws_path=""
        aws_path=$(which aws || true)
        [[ -n "$aws_path" ]] && logger "aws_path = ${aws_path}"
        if [[ "$aws_path" =~ ^qemu-aarch64.* ]]; then
            logger "Failed to install AWS CLI - Make sure AWS_CLI_ARCH is set properly, current value is ${provided_arch}" "1"
        elif [[ "$aws_path" =~ ^.*aws.*not.*found || -z "$aws_path" ]]; then
            # Fresh install
            ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli
        else
            # Update
            ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
        fi
    else
        logger "Couldn't install the provided AWS CLI version: ${_version}" "1"
    fi
    logger "AWS CLI was installed successfully"
}

# DEFAULT VALUES
_DEAFULT_ARCH="arm64"
_DEFAULT_VERSION="2"

# GLOBAL VARIABLES
_AWS_CLI_VERSION="${1:-"$AWS_CLI_VERSION"}"
_AWS_CLI_VERSION="${_AWS_CLI_VERSION:-"$_DEFAULT_VERSION"}"

_OUTPUT_AWS_FILE="awscliv${_AWS_CLI_VERSION}.zip"

_AWS_CLI_ARCH="${2:-"$AWS_CLI_ARCH"}"
_AWS_CLI_ARCH="${_AWS_CLI_ARCH,,}"
_AWS_CLI_ARCH="${_AWS_CLI_ARCH:-"$_DEAFULT_ARCH"}"

_WORKDIR="$PWD/awscli"

set_workdir "$_WORKDIR"
check_download_tool
_AWS_CLI_URL=$(get_aws_cli_url "$_AWS_CLI_VERSION" "$_AWS_CLI_ARCH" 2>&1)
download_aws_cli "$_AWS_CLI_URL" "$_OUTPUT_AWS_FILE"
install_aws_cli "$_OUTPUT_AWS_FILE" "$_AWS_CLI_VERSION" "$_AWS_CLI_ARCH"
