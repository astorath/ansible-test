#!/usr/bin/env bash

echo /run.sh "$@"
echo PYTHON_VERSION=${PYTHON_VERSION}

cd /test/ansible

if [ -z "$1" ]; then
    echo "Running in manual mode"
    source hacking/env-setup
    cd /test
    bash
    exit 0
fi

if [ "$1" = "sanity" ]; then
    echo "Running sanity tests for ${@:2}"
    source hacking/env-setup
    ansible-test sanity --python ${PYTHON_VERSION} --base-branch devel \
        "${@:2}"
fi

if [ "$1" = "integration" ]; then
    echo "Running integration $2 tests in "${@:3}" containers"
    echo LOG_LEVEL=${LOG_LEVEL}
    echo FILTER_TAGS=${FILTER_TAGS}
    source hacking/env-setup
    args=( -"${LOG_LEVEL}" )
    [ -z "$FILTER_TAGS" ] || args+=( --tags "$FILTER_TAGS" )
    for i in "${@:3}"; do
        ansible-test integration $2 --docker $i "${args[@]}"
    done
fi

if [ "$1" = "units" ]; then
    echo "Running unit tests in fedora28 container for ${@:2}"
    echo LOG_LEVEL=${LOG_LEVEL}
    source hacking/env-setup
    for i in "${@:2}"; do
        ansible-test units $i --docker fedora28 -${LOG_LEVEL}
    done
fi
