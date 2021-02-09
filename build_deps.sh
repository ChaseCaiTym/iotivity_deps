#!/bin/bash

#
# Copyright © 2018-2019 Qualcomm Technologies, Inc. and/or its subsidiaries. All rights reserved.
#

echo "Installing Cocoapods..."
which -s pod
if [[ $? != 0 ]] ; then
    # Install Cocoapods
    sudo gem install cocoapods
else
    pod repo update
fi

echo "Installing Homebrew..."
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew update
fi

echo "Installing Dependencies..."

brew install boost
brew install pkg-config
python2.7 -m ensurepip --default-pip
python -m pip install scons
brew install python

pip3 install --upgrade pip setuptools wheel
pip3 install virtualenv

echo "Fetching Iotivity..."
git clone https://github.com/iotivity/iotivity iotivity_vt || exit 1

echo "Patching Iotivity..."
cd iotivity_vt
git checkout -b rel-1.3.1 1.3.1
git apply < ../mobapps-ios-vt-sdk/ios-vt-patch.patch

echo "Fetching Crypto Deps..."
git clone https://github.com/01org/tinycbor.git extlibs/tinycbor/tinycbor -b v0.4.1 || exit 1
git clone https://github.com/ARMmbed/mbedtls.git extlibs/mbedtls/mbedtls -b mbedtls-2.4.2 || exit 1

echo "Fetching sqlite3"
mkdir -p extlibs/sqlite3
cd extlibs/sqlite3
curl https://www.sqlite.org/2015/sqlite-amalgamation-3081101.zip -o sqlite-amalgamation-3081101.zip || exit 1
cd ../..

echo "Building Iotivity"
./auto_build.py darwin
cd ..

echo "Copying Iotivity"
mkdir -p mobapps-ios-vt-sdk/IoTivity
cp -R iotivity_vt/out/ios mobapps-ios-vt-sdk/IoTivity/ios

echo "Removing Iotivity Source"
rm -rf iotivity_vt

echo "Installing pods...."
pod install || exit 1