#!/bin/env zsh

export LANG=en_US.UTF-8

# export AR="/mnt/media/Archivos"

export EDITOR='nvim'
export VISUAL='nvim'
export DOT="$HOME/dotfiles"
export TERMINAL=kitty
export PAGER='less'
export MANPAGER="sh -c 'col -bx | bat --theme=Monokai\ Extended -l man -p'" # Using "bat" as a manpager
export FZF_DEFAULT_OPTS="--layout=reverse --info=inline -i"
export GRAVEYARD="$XDG_DATA_HOME/trash"
export HISTFILE="$ZSH_DATA/history"
export _ZO_ECHO=1
export _ZO_RESOLVE_SYMLINKS=1
# export BROWSER=/usr/bin/xdg-open

# export PYENV_ROOT="$HOME/.pyenv"

typeset -U path PATH

path+=(
  $CARGO_HOME/bin(N-/)
  $GOROOT/bin(N-/)
  $GOBIN(N-/)
  $HOME/.local/bin(N-/)
  $HOME/scripts(N-/)
  $HOME/bin(N-/)
  $PYENV_ROOT/bin(N-/)
  $PIPX_BIN_DIR(N-/)
  $ZSH_DATA/completions(N-/)
)

export PATH
