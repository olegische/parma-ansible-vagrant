#!/bin/bash

# Wrapper for ansible | vagrant installation or removement.
# Vagrant installation or removement depends on ansible,
# so ansible will be installed before operations with vagrant 
# if it doesn't exists in OS, and will be removed after 
# operations with vagrant.
#
# Oleg Romanchuk, 2019-08-20, olromanchuk@gmail.com

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $SCRIPT_DIR/lib/parma-task-srv-functions.sh
source $SCRIPT_DIR/lib/const.sh
source $SCRIPT_DIR/lib/common-functions.sh

# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# PLAYBOOK_DIR="${SCRIPT_DIR}/playbooks/prov"

USAGE_TXT="Install or remove Ansible and Vagrant services"

usage( )
{
    cat <<EOF
$USAGE_TXT
Usage:
    $PROGRAM [ --? ]
        [ --help ]
        [ --version ]
        [ --install ]
        [ --remove ]
        <service name (ansible|vagrant)>
    --install
      Install and config service

    --remove
      Remove service

    Service name: script works only with ansible and vagrant services.
    Vagrant service requires ansible.
EOF
}

PROGRAM=`basename $0`
VERSION=2.0

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
    --install | --instal | --insta | --inst | --ins | --in | --i | \
    -install | -instal | -insta | -inst | -ins | -in | -i )
        cmnd='install'
        ;;
    --remove | --remov | --remo | --rem | --re | --r | \
    -remove | -remov | -remo | -rem | -re | -r )
        cmnd='remove'
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

# Sanity checks for error conditions
if [ $cmnd == 'no' ]; then
    error "Please, choose --install or --remove option."
elif [ $# -eq 0 ]; then
    error "Please, enter service name (ansible | vagrant)"
elif [ $1 != 'ansible' ] && [ $1 != 'vagrant' ]; then
    error "Please, enter correct service name (ansible | vagrant)"
elif [ ! -d $PLAYBOOK_DIR ]; then
    error "Can't find playbook directory. Please, download whole script directory."
fi
# Sanity checks end

srv_nm_1="no"
srv_nm_2="no"

srv_nm_1=$1 && shift

if [ $# -gt 0 ]; then
    srv_nm_2=$1 && shift
fi

# Sanity checks for error conditions
if [ $srv_nm_2 != 'no' ] && [ $srv_nm_2 != 'ansible' ] && [ $srv_nm_2 != 'vagrant' ]; then
    echo "Incorrect second service name. Service $srv_nm_1 will be modified."
fi
# Sanity checks end

for srv_nm in $srv_nm_1 $srv_nm_2
do
    if [ $srv_nm == 'no' ]; then
        break
    fi

# Echo all commands for testing. Use sh for execute script.
    service_worker $srv_nm $cmnd | \
    while read operation; do
        echo $operation
#    done
    done | sh

done

exit 0