#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-/tmp/dotfiles}"

task_install_stow() {
  echo "Installing stow..."
  sudo apt-get update -qq
  sudo apt-get install -y -qq stow
}

install_targets() {
  echo "Using dotfiles from: $DOTFILES_DIR"
  cd "${DOTFILES_DIR}/targets" || exit 1

  echo "DEBUG::: $(pwd)"
  for dir in */; do
    cmd=${dir%/}
    if ! command -v "$cmd" &>/dev/null; then
      echo "Skipping $dir as it is not a command."
      continue
    fi
    echo "Stowing $cmd configuration..."
    stow --target="$HOME" -v "$dir"
  done
}

task_main() {
  echo "Checking for stow..."
  if ! command -v stow &>/dev/null; then
    task_install_stow
  else
    echo "stow is already installed."
  fi

  install_targets

}

task_main
