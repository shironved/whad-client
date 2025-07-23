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
  echo "Downloading standalone Python 3.10.18..."
  wget https://github.com/astral-sh/python-build-standalone/releases/download/20250712/cpython-3.10.18+20250712-x86_64-unknown-linux-gnu-install_only.tar.gz -O $RALPM_TMP_DIR/cpython-3.10.18.tar.gz
  
  echo "Extracting Python..."
  tar xf $RALPM_TMP_DIR/cpython-3.10.18.tar.gz -C $RALPM_PKG_INSTALL_DIR
  rm $RALPM_TMP_DIR/cpython-3.10.18.tar.gz

  echo "Installing WHAD using pip..."
  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.10 install --upgrade pip setuptools wheel
  $RALPM_PKG_INSTALL_DIR/python/bin/pip3.10 install whad

  echo "Creating symlink for whad command..."
  ln -sf $RALPM_PKG_INSTALL_DIR/python/bin/whad $RALPM_PKG_BIN_DIR/whad

  echo "Installation complete. You can now run 'whad' from your PATH."
}

uninstall() {
  echo "Removing WHAD and Python standalone installation..."
  rm -rf  $RALPM_PKG_BIN_DIR/python
  rm -f $RALPM_PKG_BIN_DIR/whad
  echo "Uninstallation complete."
}

run() {
  if [[ "$1" == "install" ]]; then
    install
  elif [[ "$1" == "uninstall" ]]; then
    uninstall
  else
    show_usage
    exit 1
  fi
}

check_env
run $1
