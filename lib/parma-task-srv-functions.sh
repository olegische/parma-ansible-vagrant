#! /bin/bash

function packages_worker () {
    local pkg_mngr=$1 && shift
    local cmnd=$1 && shift
    for pkg in $@
    do
        echo "$pkg_mngr $cmnd -y $pkg"
    done
    echo "$pkg_mngr autoremove -y"
}

function ansible_os_specific () {
    local cmnd=$1 && shift
    local apt_repo_remove='no'
    local pkg_mngr=''
    local pkgs=''

    if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] ; then
        pkg_mngr='yum'
        pkgs='epel-release ansible openssl'
        if [ $cmnd == 'remove' ]; then
            pkgs='epel-release ansible'
        fi
	  elif [ -f /etc/debian_version ]; then
        pkg_mngr='apt-get'
        pkgs='ansible openssl'
        if [ $cmnd == 'remove' ]; then
            pkgs='ansible'
        fi
        if [ $cmnd == 'install' ]; then
            apt_repo_remove='yes'
            echo "echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' > /etc/apt/sources.list.d/ansible.list"
            echo "apt-key adv --keyserver 'keyserver.ubuntu.com' --recv-keys '93C4A3FD7BB9C367'"
            echo "$pkg_mngr update -y"
        else
            cmnd='purge'
        fi
  	else
      	local os=$(uname -s)
      	local ver=$(uname -r)
        error "Script doesn't support OS=$os VER=$ver"
	  fi

    packages_worker $pkg_mngr $cmnd $pkgs

    if [ $apt_repo_remove == 'yes' ]; then
        echo "apt-key del '93C4 A3FD 7BB9 C367'"
        echo "rm /etc/apt/sources.list.d/ansible.list"
        echo "$pkg_mngr update -y"
        echo "$pkg_mngr autoremove -y"
    fi
}

function user_choice () {
    local choice=$1 && shift
    local question=$@
#    read -p "$question " choice
    echo "echo \"$question \""
    read u_choice
    case $u_choice in
    [yY]* )
        return 0
        ;;
    [nN]* )
        return 1
        ;;
    *)
        if [ $choice == 'yes' ]; then
            return 0
        else
            return 1
        fi
        ;;
    esac
}

function playbook_worker () {
    local srv=$1 && shift
    local cmnd=$1 && shift
    local pb_type=$1 && shift
    local pb_arg=''
    local pb_val=''
    if [ $# -gt 0 ]; then
        pb_arg=$1 && shift
        pb_val=$1 && shift
    fi
    echo "ansible-playbook -i ${PLAYBOOK_DIR}/hosts ${PLAYBOOK_DIR}/${srv}-${pb_type}-${cmnd}.yml --$pb_arg \"$pb_val\""
}

function server_config () {
    local srv=$1 && shift
    local cmnd=$1 && shift
    local pb_type='cnfg'
    local pb_arg='extra-vars'
    local pb_var=''
    local pb_var_1='a'
    local pb_var_2='b'
    if [ $srv == 'ansible' ] && [ $cmnd == 'install' ]; then
        while [ $pb_var_1 != $pb_var_2 ]; do
          echo "echo 'Enter ansible ssh passphrase: '"
          read -s pb_var_1
          echo "echo 'Confirm ansible ssh passphrase: '"
          read -s pb_var_2
          if [ $pb_var_1 != $pb_var_2 ]; then
              echo "echo 'Input does not match. Type again.'"
          fi
        done
        pb_var=$( echo "ssh_passphrase=$pb_var_1" )
    fi
    playbook_worker $srv $cmnd $pb_type $pb_arg $pb_var
}

function vagrant_worker () {
# This function was created because of dependence between ansible and vagrant.
    local pb_type='srv'
    local cmnd=$1 && shift
    local remove_ansible='no'
    if [ ! $( type -path 'ansible' ) ]; then
        remove_ansible='yes'
        service_worker 'ansible' 'install'
    fi
    local pb_arg='extra-vars'
    local pb_tags=''
    if [ $cmnd == 'remove' ]; then
        server_config 'vagrant' $cmnd
        local result=1
        local question="Do you want to remove libvirt (no (default))?"
        user_choice 'no' $question
        result=$?
        if [ $result -eq 1 ]; then
            pb_arg='skip-tags'
            pb_tags='libvirt'
        fi
    fi
    playbook_worker 'vagrant' $cmnd $pb_type $pb_arg $pb_tags
    if [ $remove_ansible == 'yes' ]; then
       service_worker 'ansible' 'remove'
    fi
}

function service_worker () {
# Checking cm condition first makes code shorter and two "if" levels deep.
# Checking srv condition first makes code longer and three "if" levels deep.
    local srv=$1 && shift
    local cmnd=$1 && shift
    if [ $cmnd == 'install' ]; then
        if [ $( type -path $srv ) ]; then
            echo "$srv allready ${cmnd}ed." | sed 's/\([[:blank:]].*\)ee/\1e/' 1>&2
            return 0
        fi
        if [ $srv == 'ansible' ]; then
            ansible_os_specific $cmnd
            sed -i 's/#pipelining = False/pipelining = True/g' /etc/ansible/ansible.cfg &> /dev/null
        elif [ $srv == 'vagrant' ]; then
            vagrant_worker $cmnd
        fi
        echo "$srv --version"
        server_config $srv $cmnd
#        echo "##### $srv ${cmnd}ed #####" | sed 's/\([[:blank:]].*\)ee/\1e/'
        return 0
    elif [ $cmnd == 'remove' ]; then
        if [ ! $( type -path $srv ) ]; then
            echo "$srv allready ${cmnd}ed." | sed 's/\([[:blank:]].*\)ee/\1e/' 1>&2
            return 0
        fi
        if [ $srv == 'ansible' ]; then
            server_config $srv $cmnd
            ansible_os_specific $cmnd
        elif [ $srv == 'vagrant' ]; then
            vagrant_worker $cmnd
        fi
#        echo "##### $srv ${cmnd}ed #####" | sed 's/\([[:blank:]].*\)ee/\1e/'
        return 0
    fi
}