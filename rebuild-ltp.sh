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

src_dir="ltp"
cur_dir=$PWD

[ ! -d $src_dir ] && echo "Source directory $src_dir not present" && exit 1

git submodule status | grep -q "^-"
if [[ $? == 0 ]]; then
	echo "Updating submodules"

	git remote -v  | grep -q 'origin.*https'
	if [[ $? == 0 ]]; then
		echo "Using https for submodules"
		sed -i 's#ssh://git@#https://#' .gitmodules
	fi

	git submodule init
	git submodule update
fi

check_packages()
{
	local plist="bison byacc flex make autoconf automake m4 libaio libaio-devel"
	for pkg in $plist; do
		yum -q --disableplugin=fastestmirror list installed $pkg
		if [[ $? -ne 0 ]]; then
			echo "Error: Please install package [$pkg] first"
			exit 1
		fi
	done
}

check_packages

pushd $src_dir

sudo rm -rf install/*

make clean > /dev/null 2>&1
make autotools
./configure
make -j32 all
make SKIP_IDCHECK=1 DESTDIR=$cur_dir/install install

popd
