#!/bin/bash

# Copyright (c) 2013, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#
#     * Neither the name of Intel Corporation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

install_dir=install
mnt=/mnt/pmfs

[ -z "$(mount | grep $mnt)" ] && echo "Exiting: PMFS ($mnt) is not mounted " && exit 1
[ ! -d $install_dir ] && echo "Run from default location" && exit 1

if [ ! -d $install_dir/opt ]; then
	echo "Using rebuild-ltp.sh to build LTP first"
	./rebuild-ltp.sh
	[[ $? -ne 0 ]] && exit $?
	if [ ! -x $install_dir/opt/ltp/runltp ]; then
		echo "Build failed, check for errors in build.log"
		rm -rf $install_dir/opt
		exit 3
	fi
fi

runtest=$1
[ -z "$runtest" ] && runtest="pmfs-full"

pushd $install_dir/opt/ltp

[ -d output ] && rm -f output/*
[ -d results ] && rm -f results/*

sudo rm -rf $mnt/* $mnt/.[a-z]*
sudo ./runltp -f $runtest -d $mnt -g LTP_out.html

popd

rm -f LTP*
sudo mv $install_dir/opt/ltp/output/* .
sudo mv $install_dir/opt/ltp/results/* .
[ -z "$(pgrep -f syslogd)" ] && sudo service rsyslog start
