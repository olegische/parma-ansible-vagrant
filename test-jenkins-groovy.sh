#! /bin/bash

# Test groovy script in selected jenkins server.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $SCRIPT_DIR/lib/const.sh
source $SCRIPT_DIR/lib/common-functions.sh

JENKINS_GROOVY_DIR="${PLAYBOOK_DIR}/roles/jenkins/groovy"
USAGE_TXT="Test groovy script in selected jenkins server"

usage( )
{
    cat <<EOF
$USAGE_TXT
Usage:
    $PROGRAM [ --? ]
        [ --help ]
        [ --version ]
        [ --script ] <scriptname>
        [ --host ] <hostname>

    --script SCRIPTNAME
      Name of testing script (<name>.groovy).

    --host HOSTNAME
      Jenkins server hostname from inventory.

EOF
}

PROGRAM=`basename $0`
VERSION=1.0

ANSIBLE_USER="ansible"
JENKINS_VAULT_DIR="/etc/jenkins/.pass"
JENKINS_ADMIN="jenkins"

if [ $( whoami ) != $ANSIBLE_USER ]; then
    error "Run script as $ANSIBLE_USER user."
fi

if [ $# -eq 0 ]; then
    error "Choose required option for script."
fi

script='no'
host='no'

while test $# -gt 0
do
    case $1 in
    --host | --hos | --ho | --h | \
    -host | -hos | -ho | -h )
        shift
        host=$1
        ;;
    --script | --scrip | --scri | --scr | --sc | --s | \
    -script | -scrip | -scri | -scr | -sc | -s )
        shift
        script=$1
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
if [ $host == 'no' ]; then
    error "Please, use --host option to enter hostname."
elif [ $script == 'no' ]; then
    error "Please, use --script option to enter username."
elif [ ! $( type -path 'ansible' ) ]; then
    error "Please, install ansible first."
elif [ ! -d $PLAYBOOK_DIR ]; then
    error "Can't find playbook directory. Please, download whole script directory."
elif [ ! -f ${JENKINS_GROOVY_DIR}/${script} ]; then
    error "Can't find groovy file."
fi
# Sanity checks end


function getJenkinsAdminPass () {
    local host=$1 && shift

    echo "$(ansible-vault view ${JENKINS_VAULT_DIR}/${host}.${JENKINS_ADMIN} --vault-id ~${ANSIBLE_USER}/.vault_pass/prov_pass)"
}

function runScript () {
    local host=$1 && shift
    local script=$1 && shift
    local pass=$1 && shift

    echo "ansible-playbook -i ${PLAYBOOK_DIR}/hosts \
        ${PLAYBOOK_DIR}/$(echo "$PROGRAM" | sed 's/\.sh/\.yml/') \
        --extra-vars \"jenkins_script=${script} jenkins_host=${host} jenkins_admin_password=${pass}\" \
        --ask-become-pass"
}

pass=$(getJenkinsAdminPass $host)
#runScript $host $script $pass
runScript $host $script $pass | sh

exit 0