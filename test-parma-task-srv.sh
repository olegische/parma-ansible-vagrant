#!/bin/bash

script_name="parma-task-srv.sh"
act_arr=("--i" "-r")
srv_arr=(ansible vagrant)
is_control=true

function test_script () {
    cntrl=$1 && shift
    echo "==========COMMAND=========="
    echo "./${script_name} $@"
    echo "==========OUTPUT==========="
    ./${script_name} $@ &
    wait $!
    echo "==========================="
    if [ $cntrl == true ]; then
        read x
    fi
}

srv_prev="no"
for srv in ${srv_arr[*]}
do
    for act in ${act_arr[*]}
    do
        test_script $is_control $act $srv
        if [ $srv_prev != 'no' ]; then
          test_script $is_control $act $srv_prev $srv
        fi
    done
    srv_prev=$srv
done