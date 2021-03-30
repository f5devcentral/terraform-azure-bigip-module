#!/bin/sh
bigstart stop tmm
tmsh modify sys db provision.managementeth value "${1:-eth1}"
tmsh modify sys db provision.1nicautoconfig value disable
tmsh save sys config
reboot
