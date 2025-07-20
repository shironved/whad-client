#!/usr/bin/env bash
set -e

show_usage() {
  echo "Usage: $(basename $0) install|uninstall"
}

if [ $# -ne 1 ]; then
  show_usage
  exit 1
fi

check_env() {
  [[ -z "${RALPM_TMP_DIR}" ]] && echo "RALPM_TMP_DIR is not set" && exit 1
  [[ -z "${RALPM_PKG_INSTALL_DIR}" ]] && echo "RALPM_PKG_INSTALL_DIR is not set" && exit 1
  [[ -z "${RALPM_PKG_BIN_DIR}" ]] && echo "RALPM_PKG_BIN_DIR is not set" && exit 1
}

install() {
  python3 -m venv $RALPM_PKG_INSTALL_DIR/venv
  source $RALPM_PKG_INSTALL_DIR/venv/bin/activate
  pip install whad

  echo "#!/usr/bin/env bash" > $RALPM_PKG_BIN_DIR/whad
  echo "source $RALPM_PKG_INSTALL_DIR/venv/bin/activate && whad \"\$@\"" >> $RALPM_PKG_BIN_DIR/whad
  chmod +x $RALPM_PKG_BIN_DIR/whad
}

uninstall() {
  rm -rf $RALPM_PKG_INSTALL_DIR
  rm -f $RALPM_PKG_BIN_DIR/whad
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
