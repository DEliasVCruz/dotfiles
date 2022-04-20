#!/bin/env zsh

HISTSIZE=1000000
SAVEHIST=1000000

# Env Variables
# export PATH="$HOME/.poetry/bin:$PATH"
source ./.zshenv

# # Evals
# export PATH="$PYENV_ROOT/bin:$PATH"

function _init_options {
    setopt interactive_comments # Allow for comments
    setopt auto_cd              # Automaticlaly cd to directory name
    setopt nomatch              # Error if a file pattern does not match
    setopt COMBINING_CHARS      # Unicode support
    stty stop undef
    autoload edit-command-line # Edit line in vim with ctrl-e:
    zle -N edit-command-line
}

function _zstyle_completion {
    # disable sort when completing `git checkout`
    zstyle ':completion:*:git-checkout:*' sort false
    # set descriptions format to enable group support
    zstyle ':completion:*:descriptions' format '[%d]'
    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    # preview directory's content with exa when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    # switch group using `,` and `.`
    zstyle ':fzf-tab:*' switch-group ',' '.'
}

# function _debug {
# 	autoload -U colors && colors

# 	# set this variable to 1 to enable debug information
# 	if ((${DEBUG_ZSH_RC:-0} == 1)); then
# 		echo "$fg[green]INFO$reset_color: $1"
# 	fi
# }

function _init_prompt {
	if (($ + commands[starship])); then
		# _debug "initialize starship prompt"
		eval "$(starship init zsh)"
	fi
}

function zvm_config {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_ESCAPE_BINDKEY=^c
    ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
    ZVM_VI_EDITOR=nvim
    ZVM_ESCAPE_KEYTIMEOUT=0.1
}

function _init_plugin {
    # _debug "sourcing plugins"

    eval "$(starship init zsh)"

    autoload -U compinit
    compinit -d "$ZSH_DATA/.zcompdump"
}

function _init_local {
	#   source $XDG_CONFIG_HOME/zsh/zoxide.zsh
    source $XDG_CONFIG_HOME/zsh/fn.zsh
    eval "$(pyenv init -)"
    eval "$(zoxide init --cmd j --hook pwd zsh)"
}

function _init_alias {
    # Sane defaults
    alias cp="cp -i"        # confirm before overwriting something
    alias mv="mv -i"        # confirm before overwriting something
    alias mkdir='mkdir -pv' # Make parent directories and give visual feedback
    alias df='df -h'        # human-readable sizes
    alias free='free -m'    # show sizes in MB

    # Direcotry navigation
    alias l="exa -a --icons --group-directories-first"
    alias pi="nsxiv -a"              # Display image
    alias d="exa -a --icons -D"     # Display only directories
    alias ff="find . -type f -name" # Find file by name in cwd

    # Python programming language
    alias pyrepl="python -m ptpython" # The python REPL interactive shell
    alias pip="python -m pip"

    # Better utils
    alias rm="rip"
    alias cp="cn"

    # R programming language
    alias R="R --quiet" # Run R without the intro
    alias r="radian"    # The better R interactive shell

    # Editor
    alias e="nvim_night"

    # Arch package manager
    alias ins="paru -S"       # Install from the AUR
    alias s="paru -Ss --repo" # Search only on the standard repos
    alias updt="paru -Syu"    # Update repos
    alias del="paru -Rns"
    alias sa='paru -Ssa' # Search only the AUR
    alias inf="paru -Sii"

    # Mount the drive
    alias mnt="sudo mount /dev/sdb2 /mnt/media/Archivos"

    # Git aliases
    alias g="git"
    alias gss="git status -s"
    alias gds="git diff --staged HEAD"
}

_init_local
_init_prompt
_init_options
_zstyle_completion
_init_plugin
_init_local
_init_alias
