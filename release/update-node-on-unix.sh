#!/bin/bash
# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
base=$(cd "`dirname "${BASH_SOURCE[0]}"`" && pwd)
echo

##################################################
# change this as new versions of node are released
##################################################
nodeVersion=v0.10.18

################################################
# Now we download the correct version of node-js
################################################
mkdir "$base/../ext" 2>/dev/null
cd "$base/../ext"

os="`uname`-`uname -m`"
case $os in
	Darwin-x86_64) os=darwin-x64 ;;
	Darwin-i386) os=darwin-x86 ;;
	Linux-x86_64) os=linux-x64 ;;
	Linux-i386) os=linux-x86 ;;
	*) echo "Unknown OS version - '$os'"
	   echo "Compile from source at 'http://nodejs.org/dist/$nodeVersion/node-$nodeVersion.tar.gz'"
	   exit
esac
filename=node-$nodeVersion-$os
if [ ! -e $filename.tar.gz ]
then
    echo "download $filename.tar.gz from nodejs.org"
    curl -sOL http://nodejs.org/dist/$nodeVersion/$filename.tar.gz
    echo "unpack $filename"
    tar -xzf $filename.tar.gz
    rm -r node 2>/dev/null
    mkdir node
    mv $filename/* node
    rm -r $filename
fi
echo
