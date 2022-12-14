#!/bin/bash

function usage() {
    # NOTE: shellcheck complains quoting in the example so SC2086 is disabled
    # shellcheck disable=SC2086
    cat <<EOF
Usage: $(basename ${0}) [-c <clean>] [-p <kernel patch>] [-k <kernel version] [-n <network namespace>] [-o <ovl>] [-t <test case>] [-d <run in k8s environment] [-v] [-h]
    -c: Start with a clean slate. (Default false)
    -p: Kernel patch to use, custom kernel is built using the patch. (No default)
    -k: Kernel version to use. (Default 5.19.9)
    -n: Network namespace to use. (Default 1, expands to ${USER}_xcluster1)
    -o: OVL to run. (No default)
    -t: Test case to run. (No default)
    -d: Run in k8s environment. (Default false)
    -v: Run in verbose mode. (Default false)
    -h: This message.
EOF
    exit 0
}

function parse_cmdline_opts() {
    # set variables to the values set in env - otherwise, set them to defaults
    XCLUSTER_CLEAN="${XCLUSTER_CLEAN:-false}"
    KERNEL_PATCH="${KERNEL_PATCH:-}"
    KERNEL_VER="${KERNEL_VER:-5.19.9}"
    XCLUSTER_NETNS="${XCLUSTER_NETNS:-1}"
    OVL="${OVL:-}"
    TESTCASE="${TESTCASE:-}"
    K8S="${K8S:-false}"
    VERBOSE="${VERBOSE:-false}"

    # get values passed as command line arguments, overriding the defaults or
    # the ones set by using env variables
    while getopts ":hcp:k:n:o:t:dv" o; do
        case "${o}" in
        c) XCLUSTER_CLEAN="true" ;;
        p) KERNEL_PATCH="${OPTARG}" ;;
        k) KERNEL_VER="${OPTARG}" ;;
        n) XCLUSTER_NETNS="${OPTARG}" ;;
        o) OVL="${OPTARG}" ;;
        t) TESTCASE="${OPTARG}" ;;
        d) K8S="true" ;;
        v) VERBOSE="true" ;;
        h) usage ;;
        *) echo "ERROR : Invalid option '-${OPTARG}'"; usage ;;
        esac
    done
    # Do all the exports
    export XCLUSTER_CLEAN="${XCLUSTER_CLEAN}"
    export KERNEL_PATCH="${KERNEL_PATCH}"
    export KERNEL_VER="${KERNEL_VER}"
    export XCLUSTER_NETNS="${XCLUSTER_NETNS}"
    export OVL="${OVL}"
    export TESTCASE="${TESTCASE}"
    export K8s="${K8S}"
    export VERBOSE="${VERBOSE}"
}

function log_environment() {
    echo
    echo "#---------------------------------------------------#"
    echo "#                    Environment                    #"
    echo "#---------------------------------------------------#"
    echo "User             : ${USER}"
    echo "Hostname         : ${HOSTNAME}"
    echo "Host OS          : $(source /etc/os-release &> /dev/null || source /usr/lib/os-release &> /dev/null; echo "${PRETTY_NAME}")"
    echo "IP               : $(hostname -I | cut -d' ' -f1)"
    echo "Network NS       : ${USER}_xcluster${XCLUSTER_NETNS}"
    echo "#---------------------------------------------------#"
    echo
}

function log_execution_start() {
    echo "#---------------------------------------------------#"
    echo "#                 Execution Started                 #"
    echo "#---------------------------------------------------#"
    echo "Date & Time      : $(date -u '+%F %T UTC')"
    echo "Clean slate      : ${XCLUSTER_CLEAN}"
    test -n "${KERNEL_PATCH}" &&
    echo "Kernel patch:  ${KERNEL_PATCH}"
    echo "Kernel version   : ${KERNEL_VER}"
    echo "OVL              : ${OVL}"
    echo "Testcase         : ${TESTCASE}"
    echo "K8s environment  : ${K8S}"
    echo "Verbose          : ${VERBOSE}"
    echo "#---------------------------------------------------#"
    echo
}

function log_execution_stop() {
    elapsed_time=$SECONDS
    echo
    echo "#---------------------------------------------------#"
    echo "#                Execution Completed                #"
    echo "#---------------------------------------------------#"
    echo "Date & Time      : $(date -u '+%F %T UTC')"
    echo "Elapsed          : $((elapsed_time / 60)) minutes and $((elapsed_time % 60)) seconds"
    echo "#---------------------------------------------------#"
    echo
}
