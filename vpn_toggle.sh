#!/bin/bash

# This is a short bash script to toggle a vpn connection named my_vpn.
# I set up a custom keyboard shortcut (super+V) to run this script and allow me
# to turn on and off my work vpn very quickly.
# This should work on a linux or mac machine.

curr_conn_status=$(nmcli con show | grep my_vpn | awk '{print $4}')

if [[ "$curr_conn_status" == "--" ]]; then
    nmcli con up my_vpn
else 
    nmcli con down my_vpn
fi

