#!/usr/bin/env bash

set -e
set -o pipefail

_DOCKER_FILE_DIR="${1:-"$PWD"}"
_DOCKER_IMAGE_NAME="${2:?"Image name not set"}"
_DOCKER_FILE_NAME="$3"

is_docker_install(){
    if ! which docker 1>/dev/null; then
        echo "Docker is not installed"
        exit 1
    fi
}

clean_up(){
    echo "[CLEANING UP IMAGE]"
    docker image rm "$_DOCKER_IMAGE_NAME" 
}

build_image(){
    if [[ -z $_DOCKER_FILE_NAME ]]; then
        docker image build "$_DOCKER_FILE_DIR" -t "$_DOCKER_IMAGE_NAME" -f "$_DOCKER_FILE_NAME"
    else
        docker image build "$_DOCKER_FILE_DIR" -t "$_DOCKER_IMAGE_NAME" 
    fi
}

run_image(){
    if ! docker container run --rm "$_DOCKER_IMAGE_NAME" ; then 
        echo "[CONTAINER EXECUTION FAILED]"
        clean_up
    else
        clean_up
    fi
}


is_docker_install

build_image

run_image
