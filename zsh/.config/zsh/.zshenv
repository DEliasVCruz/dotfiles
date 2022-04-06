#!/bin/env zsh

export LANG=en_US.UTF-8

# export AR="/mnt/media/Archivos"

export EDITOR='nvim'
export VISUAL='nvim'
export DOT=$HOME/dotfiles
export PAGER='less'
export MANPAGER="sh -c 'col -bx | bat -l man -p'" # Using "bat" as a manpager
export FZF_DEFAULT_OPTS="--layout=reverse --info=inline -i"
export GRAVEYARD="$XDG_DATA_HOME/trash"
export _ZO_ECHO=1
export _ZO_RESOLVE_SYMLINKS=1
# export BROWSER=/usr/bin/xdg-open

# export PYENV_ROOT="$HOME/.pyenv"

export BAT_THEME="1337"

typeset -U path PATH

path+=(
  $HOME/.cargo/bin(N-/)
  $GOPATH/bin(N-/)
  $GOROOT/bin(N-/)
  $HOME/.local/bin(N-/)
  $HOME/scripts(N-/)
  $PYENV_ROOT/bin(N-/)
  # $PYENV_ROOT/bin(N-/)
  $HOME/.poetry/bin(N-/)
  # $path
)

export PATH
