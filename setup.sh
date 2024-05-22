#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $RALPM_TMP_DIR/cpython-3.9.13.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/cruise-automation/fwanalyzer/archive/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz -O $RALPM_TMP_DIR/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz
  tar xf $RALPM_TMP_DIR/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz -C $RALPM_TMP_DIR
  mv $RALPM_TMP_DIR/fwanalyzer-0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23/devices $RALPM_PKG_INSTALL_DIR
  mv $RALPM_TMP_DIR/fwanalyzer-0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23/scripts $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23.tar.gz
  rm -rf $RALPM_TMP_DIR/fwanalyzer-0b96fc145b9a927d0fd3b6f06fdda535f8dc1a23

  wget https://github.com/RAL0S/fwanalyzer/releases/download/v1.4.3/fwanalyzer-build.tar.gz -O $RALPM_TMP_DIR/fwanalyzer-build.tar.gz
  tar xf $RALPM_TMP_DIR/fwanalyzer-build.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/fwanalyzer-build.tar.gz

  echo "#!/bin/bash" > $RALPM_PKG_BIN_DIR/fwanalyzer
  echo "PATH=$RALPM_PKG_INSTALL_DIR/bin/:$RALPM_PKG_INSTALL_DIR/scripts/:$RALPM_PKG_INSTALL_DIR/python/bin/:\$PATH $RALPM_PKG_INSTALL_DIR/bin/fwanalyzer \"\$@\"" >> $RALPM_PKG_BIN_DIR/fwanalyzer
  chmod +x $RALPM_PKG_BIN_DIR/fwanalyzer

  echo "#!/bin/bash" > $RALPM_PKG_BIN_DIR/fwanalyzer.check
  echo "PATH=$RALPM_PKG_INSTALL_DIR/bin/:$RALPM_PKG_INSTALL_DIR/scripts/:$RALPM_PKG_INSTALL_DIR/python/bin/:\$PATH $RALPM_PKG_INSTALL_DIR/python/bin/python3.9 $RALPM_PKG_INSTALL_DIR/devices/check.py \"\$@\"" >> $RALPM_PKG_BIN_DIR/fwanalyzer.check
  chmod +x $RALPM_PKG_BIN_DIR/fwanalyzer.check

  sed -i "1c #!$RALPM_PKG_INSTALL_DIR/python/bin/python3.9" $RALPM_PKG_INSTALL_DIR/devices/check.py
  sed -i "1c #!$RALPM_PKG_INSTALL_DIR/python/bin/python3.9" $RALPM_PKG_INSTALL_DIR/devices/android/check_ota.py
  sed -i "1c #!$RALPM_PKG_INSTALL_DIR/python/bin/python3.9" $RALPM_PKG_INSTALL_DIR/scripts/prop2json.py

  echo "This package adds the following commands:"
  echo " - fwanalyzer"
  echo " - fwanalyzer.check"
}

uninstall() {
  rm -rf $RALPM_PKG_INSTALL_DIR/*
  rm $RALPM_PKG_BIN_DIR/fwanalyzer
  rm $RALPM_PKG_BIN_DIR/fwanalyzer.check
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1