#!/bin/bash
#
# Create a unique ssh keypair
#

[ ! -d keys ] && mkdir -p keys
if [ ! -f keys/id_rsa ]; then
    echo "Create ansible ssh keypair"
    ssh-keygen -b 4096 -t rsa -f keys/id_rsa -q -N ""
fi