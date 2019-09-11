#! /bin/bash

# Script for getting ansible client's user password from vault.

source $SCRIPT_DIR/lib/const.sh
source $SCRIPT_DIR/lib/common-functions.sh

# SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# PLAYBOOK_DIR="${SCRIPT_DIR}/playbooks/prov"

USAGE_TXT="Get user password from ansible vaults"

usage( )
{
    cat <<EOF
$USAGE_TXT
Usage:
    $PROGRAM [ --? ]
        [ --help ]
        [ --version ]
        [ --vault ] <vaultname>
        [ --host ] <hostname>
        [ --user ] <username>

    --vault VAULTNAME
      Ansible vault type.

    --host HOSTNAME
      Ansible client's hostname from inventory.

    --user USERNAME
      Client's username.

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

ANSIBLE_USER="ansible"
VAULT_ID_DIR="/home/${ANSIBLE_USER}/.vault_pass"
VAULT_ID_LABEL="prov"
VAULT_ID="${VAULT_ID_DIR}/${VAULT_ID_LABEL}_pass"

host='no'
user='no'
vault='no'

while test $# -gt 0
do
    case $1 in
    --host | --hos | --ho | --h | \
    -host | -hos | -ho | -h )
        shift
        host=$1
        ;;
    --user | --use | --us | --u | \
    -user | -use | -us | -u )
        shift
        user=$1
        ;;
    --vault | --vaul | --vau | --va | --v | \
    -vault | -vaul | -vau | -va | -v )
        shift
        vault=$1
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
elif [ $user == 'no' ]; then
    error "Please, use --user option to enter username."
elif [ $vault == 'no' ]; then
    error "Please, use --vault option to enter vaultname."
elif [ ! $( type -path 'ansible' ) ]; then
    error "Please, install ansible first."
elif [ ! -d $PLAYBOOK_DIR ]; then
    error "Can't find playbook directory. Please, download whole script directory."
fi
# Sanity checks end

vault_pass_dir="/etc/${vault}/.pass"
vault_file="${vault_pass_dir}/${host}.${user}"

if [ ! -d $vault_pass_dir ]; then
    error "No such vault."
elif [ ! -f "$vault_file" ]; then
    error "No such host or user."
fi

function get_pass () {
    local vault=$1 && shift
    local host=$1 && shift
    local vault_file=$1 && shift
    if [ $vault == 'ansible' ] && [ $host == 'localhost' ]; then
        echo "ansible-vault view ${vault_file} --ask-vault-pass"
    else
        echo "ansible-vault view ${vault_file} --vault-id ${VAULT_ID}"
    fi
}

#get_pass $vault $host $vault_file
get_pass $vault $host $vault_file | sh

exit 0