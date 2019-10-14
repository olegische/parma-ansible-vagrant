#! /bin/bash

# Script for checking RAM capacity and starting environment.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $SCRIPT_DIR/lib/const.sh
source $SCRIPT_DIR/lib/common-functions.sh

# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# PLAYBOOK_DIR="${SCRIPT_DIR}/playbooks/prov"

USAGE_TXT="Up or destroy test task environment"

usage( )
{
    cat <<EOF
$USAGE_TXT
Usage:
    $PROGRAM [ --? ]
        [ --help ]
        [ --version ]
        [ --up ]
        [ --destroy ]

    --up
      Run and provision environment virtual machines

    --destroy
      Destroy environment virtual machines

EOF
}

PROGRAM=`basename $0`
VERSION=1.0

if [ $( whoami ) != 'root' ]; then
    error "Run script as root user."
fi

if [ $# -eq 0 ]; then
    error "Choose required option for script."
fi

cmnd="no"
while test $# -gt 0
do
    case $1 in
    --up | --u | -up | -u )
        cmnd='up' && break
        ;;
    --destroy | --destro | --destr | --dest | --des | --de | --d | \
    -destroy | -destro | -destr | -dest | -des | -de | -d )
        cmnd='destroy' && break
        ;;
    --help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
        usage_and_exit 0
        ;;
    --version | --versio | --versi | --vers | --ver | --ve | --v | \
    -version | -versio | -versi | -vers | -ver | -ve | -v )
        version
        exit 0
        ;;
    -*)
        error "Unrecognized option: $1."
        ;;
    *)
        break
        ;;
    esac
    shift
done

MIN_RAM=$(( 4096 + 1024 + 1024 ))
RAM=$( free -m | sed -n 2p | awk ' match($0, /Mem:[[:blank:]]*?([0-9]{4})/, m) {print m[1]} ' )

# Sanity checks for error conditions
if [ $cmnd == 'no' ]; then
    error "Please, choose --up or --destroy option."
elif [ ! $( type -path 'vagrant' ) ]; then
    error "Please, install vagrant first."
elif [ ! $( type -path 'ansible' ) ]; then
    error "Please, install ansible first."
elif [ ! -d $PLAYBOOK_DIR ]; then
    error "Can't find playbook directory. Please, download whole script directory."
elif [ $MIN_RAM -gt $RAM ]; then
    error "PC doesn't have enought RAM for run gitlab and jenkins virtual machines."
fi
# Sanity checks end

function env_worker () {
    local cmnd=$1 && shift
    if [ $cmnd == 'up' ]; then
        vagrant up
    else
        vagrant destroy
        ansible-playbook -i ${PLAYBOOK_DIR}/hosts ${PLAYBOOK_DIR}/environment-${cmnd}.yml
    fi
}

env_worker $cmnd

exit 0