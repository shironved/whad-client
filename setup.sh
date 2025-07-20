#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename "$0") takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]; then
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
  local install_dir="${RALPM_PKG_INSTALL_DIR}/whad-client"
  local launcher="${RALPM_PKG_BIN_DIR}/whad-client"

  echo "Cloning WHAD client repository..."
  git clone --recurse-submodules --remote-submodules https://github.com/whad-team/whad-client.git "$install_dir"

  echo "Creating Python virtual environment..."
  python3 -m venv "$install_dir/venv"

  echo "Installing WHAD client in virtual environment..."
  source "$install_dir/venv/bin/activate"
  pushd "$install_dir" > /dev/null
  pip install --upgrade pip setuptools
  pip install .
  popd > /dev/null
  deactivate

  echo "Creating WHAD client launcher..."
  cat <<EOF > "$launcher"
#!/usr/bin/env bash
source "$install_dir/venv/bin/activate"
python -m whad_client "\$@"
deactivate
EOF

  chmod +x "$launcher"
  echo "WHAD client installation complete."
}

uninstall() {
  echo "Removing WHAD client..."
  rm -rf "${RALPM_PKG_INSTALL_DIR}/whad-client"
  rm -f "${RALPM_PKG_BIN_DIR}/whad-client"
  echo "WHAD client uninstalled."
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
run "$1"
