# Local language
export LC_ALL="en_US.UTF8"

# XDG standard directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Language bin folders
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export GOROOT="/usr/local/go"
export GOPATH="$XDG_DATA_HOME/go"
# export PATH="$PATH:$XDG_DATA_HOME/yarn/bin"

# General user directories
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Initialize pyenv path
export PATH="$PYENV_ROOT/bin:$PATH" && eval "$(pyenv init --path)"

if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
	exec sx ~/.config/x11/xinitrc
fi