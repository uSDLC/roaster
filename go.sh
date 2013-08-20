#!/bin/bash
#echo "Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license"
echo
# The go script is in the root directory of uSDLC2 Node
export uSDLC_base_path=$(pwd)
export uSDLC_node_path=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
# node require statements will look here
export NODE_PATH=.:$uSDLC_base_path/server:$uSDLC_base_path/scripts:$uSDLC_node_path:$uSDLC_node_path/server:$uSDLC_node_path/node_modules:$uSDLC_node_path/ext/node_modules:$uSDLC_node_path/ext/node/lib/node_modules:$uSDLC_node_path/scripts:$NODE_PATH
# add scripts and node itself to the path for convenience
export PATH=$uSDLC_node_path/ext/node/bin:$PATH

$uSDLC_node_path/release/update-node-on-unix.sh

node $DEBUG_NODE "$uSDLC_node_path/boot/load.js" "boot/run" $@
