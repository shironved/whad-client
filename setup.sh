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
  echo "Installing whad-client via pip..."

  # Execute the pip install command directly
  # Adding --break-system-packages for modern Debian/Ubuntu systems
  # If this is not allowed by RALPM's policy, this method would need reconsideration.
  pip3 install whad --break-system-packages

  # Create a simple wrapper script in RALPM_PKG_BIN_DIR
  # This assumes 'whad' executable is now directly callable on the system PATH
  echo "#!/usr/bin/env bash" > "$RALPM_PKG_BIN_DIR/whad"
  echo "exec whad \"\$@\"" >> "$RALPM_PKG_BIN_DIR/whad" # 'exec' replaces the current shell with the whad command
  chmod +x "$RALPM_PKG_BIN_DIR/whad"

  echo "========================="
  echo "Successfully installed whad-client."    
  echo "Run 'whad --help' for usage."
  echo "========================="
}

uninstall() {
  echo "Uninstalling whad-client..."

  # Execute the pip uninstall command directly
  pip3 uninstall --yes whad

  # Remove the wrapper script from RALPM_PKG_BIN_DIR
  rm -f "$RALPM_PKG_BIN_DIR/whad"

  echo "whad-client uninstalled successfully."
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
run "$1"
