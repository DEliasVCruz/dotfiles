#!/bin/env zsh

export LANG=en_US.UTF-8

# export AR="/mnt/media/Archivos"

export EDITOR='nvim'
export VISUAL="$EDITOR"
export PAGER='less'
export MANPAGER="sh -c 'col -bx | bat --theme=Monokai\ Extended -l man -p'" # Using "bat" as a manpager
export FZF_DEFAULT_OPTS="--layout=reverse --info=inline -i"
export _ZO_ECHO=0
export _ZO_RESOLVE_SYMLINKS=1
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export AWS_PROFILE="staging"
export NVIM_HOME="/opt/nvim-linux-x86_64"
# export ANDROID_SDK_ROOT="/mnt/c/Users/danie/AppData/Local/Android/Sdk"
# export ANDROID_HOME="/mnt/c/Users/danie/AppData/Local/Android/Sdk"
# export BROWSER=/usr/bin/xdg-open

typeset -U path PATH

path+=(
  $CARGO_HOME/bin(N-/)
  $GOROOT/bin(N-/)
  $GOBIN(N-/)
  $BUN_BIN(N-/)
  $XDG_LOCAL_HOME/bin(N-/)
  $HOME/bin(N-/)
  $PYENV_ROOT/bin(N-/)
  $PIPX_BIN_DIR(N-/)
  $ZSH_DATA/completions(N-/)
  $COURSIER_BIN_DIR(N-/)
  $HOME/.atuin/bin(N-/)
  $HOME/development/flutter/bin(N-/)
  $JAVA_HOME/bin(N-/)
  $NVIM_HOME/bin(N-/)
  # $ANDROID_SDK_ROOT/platform-tools(N-/)
)

export PATH

typeset -U fpath FPATH

fpath+=(
  $ZSH_DATA/completions(N-/)
)

export FPATH
