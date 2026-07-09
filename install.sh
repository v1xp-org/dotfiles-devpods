#!/usr/bin/env bash

set -euo pipefail

logfile=~/.dotfiles.log

# Source devpod env if available (GPG, SSH, API keys, git identity)
if [ -d /tmp/keys ]; then
  source /tmp/keys/setup.sh 2>/dev/null || true
fi

install_targets() {
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "$0")" && pwd)"
  echo "Using dotfiles from: $dotfiles_dir"

  # Copy dotfiles to a persistent location so symlinks survive container restarts
  local persist_dir="$HOME/.local/share/dotfiles"
  mkdir -p "$persist_dir"
  cp -a "$dotfiles_dir/." "$persist_dir/"
  echo "Dotfiles persisted to $persist_dir"

  local targets_dir="$persist_dir/targets"
  for target_dir in "$targets_dir"/*/; do
    local cmd
    cmd="$(basename "$target_dir")"
    if [[ "$cmd" != "bin" ]] && ! command -v "$cmd" &>/dev/null; then
      echo "Skipping $cmd as it is not a command."
      continue
    fi
    echo "Stowing $cmd configuration..."

    while IFS= read -r -d '' f; do
      local rel="${f#"$target_dir"}"
      local dest="$HOME/$rel"
      if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "  BACKUP: $dest -> $dest.stow-bak"
        mv "$dest" "$dest.stow-bak"
      fi
    done < <(find "$target_dir" -type f -print0)

    (cd "$targets_dir" && stow --target="$HOME" -v "$cmd")
  done
}

task_stow() {
  if ! command -v stow &>/dev/null; then
    echo "stow not found, installing..."
    sudo apt-get update -qq && sudo apt-get install -y -qq stow
  fi
  install_targets
}

task_git() {
  git config --global commit.gpgsign true

  # Dynamic signing key detection (may fail if GPG agent isn't ready)
  SIGNING_KEY=$(gpg --list-secret-subkeys --keyid-format long 2>/dev/null | grep "^\s*ssb" | head -1 | awk '{print $2}' | cut -d'/' -f2 || true)

  # If no subkey found, try primary key
  if [ -z "$SIGNING_KEY" ]; then
    SIGNING_KEY=$(gpg --list-secret-keys --keyid-format long 2>/dev/null | grep "^sec" | head -1 | awk '{print $2}' | cut -d'/' -f2 || true)
  fi

  if [ -n "$SIGNING_KEY" ]; then
    git config --global user.signingkey "$SIGNING_KEY"
  fi

  # Personal config from env vars (set in ~/.devpod-keys/env.sh)
  if [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
  fi
  if [ -n "${GIT_USER_NAME:-}" ]; then
    git config --global user.name "$GIT_USER_NAME"
  fi
}

task_ssh() {
  # In devpod containers, keys live in /home/vscode/.ssh-host (bind-mounted from host)
  # $HOME may be /home/victor due to host user, so check the hardcoded path too
  local ssh_host=""
  for p in /home/vscode/.ssh-host "$HOME/.ssh-host"; do
    if [ -d "$p" ] && ls "$p"/id_* &>/dev/null; then
      ssh_host="$p"
      break
    fi
  done

  if [ -n "$ssh_host" ]; then
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    cp "$ssh_host"/id_* "$HOME/.ssh/" 2>/dev/null || true
    cp "$ssh_host"/known_hosts "$HOME/.ssh/" 2>/dev/null || true
    chmod 600 "$HOME"/.ssh/id_* 2>/dev/null || true

    # Detect the first private key (skip *.pub files) for the SSH config
    local first_key
    first_key=$(ls "$ssh_host"/id_* 2>/dev/null | grep -v '\.pub$' | head -1)
    local key_name
    key_name=$(basename "$first_key")

    cat >"$HOME/.ssh/config" <<SSHEOF
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/${key_name}
  IdentitiesOnly yes
SSHEOF
    chmod 600 "$HOME/.ssh/config"
    echo "SSH keys copied from $ssh_host (using $key_name)"
  elif [ -n "${SSH_AUTH_SOCK:-}" ]; then
    echo "Using SSH agent forwarding (SSH_AUTH_SOCK=$SSH_AUTH_SOCK)"
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    cat >"$HOME/.ssh/config" <<SSHEOF
Host github.com
  HostName github.com
  User git
  IdentityAgent $SSH_AUTH_SOCK
SSHEOF
    chmod 600 "$HOME/.ssh/config"
  else
    echo "No SSH keys found. Configure SSH agent forwarding or mount .ssh-host."
  fi
}

task_opencode_plugins() {
  # Install graphify (knowledge graph for codebases)
  if command -v uv &>/dev/null; then
    if ! uv tool list 2>/dev/null | grep -q graphifyy; then
      echo "Installing graphify..."
      uv tool install graphifyy 2>/dev/null || echo "WARNING: graphify install failed"
    fi
  elif command -v pip &>/dev/null; then
    if ! pip show graphifyy &>/dev/null; then
      echo "Installing graphify via pip..."
      pip install graphifyy 2>/dev/null || echo "WARNING: graphify install failed"
    fi
  fi

  # Install graphify skill for opencode
  if command -v graphify &>/dev/null; then
    echo "Installing graphify skill for opencode..."
    graphify install opencode 2>/dev/null || echo "WARNING: graphify skill install failed"
    graphify opencode install 2>/dev/null || echo "WARNING: graphify opencode install failed"
  fi

  # Install opencode-ralph-loop plugin
  if command -v opencode &>/dev/null; then
    echo "ralph-loop plugin will be auto-installed by opencode on first run"
  fi
}

first_inits() {
  sudo ln -sf /usr/share/zoneinfo/America/Campo_Grande /etc/localtime

  # Pre-fetch the Portuguese spell file so Neovim never prompts
  # "No spell file found for pt (utf-8). Download? [y/N]" on first run.
  # spelllang=pt_br (see nvim options.lua) needs the base pt.utf-8.spl,
  # which Neovim does not bundle. This dir is outside the stow-managed
  # tree, so it persists across container restarts.
  local spell_dir="$HOME/.config/nvim/spell"
  mkdir -p "$spell_dir"
  if [ ! -f "$spell_dir/pt.utf-8.spl" ]; then
    curl -fsSL "https://ftp.nluug.nl/pub/vim/runtime/spell/pt.utf-8.spl" \
      -o "$spell_dir/pt.utf-8.spl" 2>/dev/null || true
  fi

  # Pre-install Neovim plugins headlessly so the first launch is fast.
  # Run detached with output to a log file so `devpod up` stays clean and
  # finishes quickly (the old command only suppressed stderr, so the
  # plugin-sync output on stdout still flooded the terminal).
  nohup nvim --headless +"set spelllang=en_us,pt_br" +qa >/tmp/nvim-init.log 2>&1 &
}

task_main() {
  local pids=()
  local errors=0

  task_stow &
  pids+=($!)
  task_git &
  pids+=($!)
  task_keys &
  pids+=($!)
  task_opencode_plugins &
  pids+=($!)

  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      echo "ERROR: Task with PID $pid failed" >&2
      errors=$((errors + 1))
    fi
  done

  if [ "$errors" -gt 0 ]; then
    echo "WARNING: $errors task(s) failed. Check log: $logfile" >&2
    return 1
  fi

  echo "All dotfiles tasks completed successfully."
  first_inits
}

task_main
