# Local language
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_COLLATE="C"

# XDG standard directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_LOCAL_HOME="$HOME/.local"
export XDG_DATA_HOME="$XDG_LOCAL_HOME/share"

# Global variables
export TERMINAL="/usr/bin/kitty"

# Language bin folders
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export GOROOT="/usr/local/go"
export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$GOPATH/bin"
export PIPX_HOME="$XDG_DATA_HOME/pipx"
export PIPX_BIN_DIR="$PIPX_HOME/bin"
export ZSH_DATA="$XDG_DATA_HOME/zsh"
# export PATH="$PATH:$XDG_DATA_HOME/yarn/bin"

# General user directories
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export DOT="$HOME/dotfiles"
export GRAVEYARD="$XDG_DATA_HOME/trash"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZSH_DATA/history"

# Initialize pyenv path
export PATH="$PYENV_ROOT/bin:$PATH" && eval "$(pyenv init --path)"

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
	exec sx ~/.config/x11/xinitrc
fi
