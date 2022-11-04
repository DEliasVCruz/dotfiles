#!/bin/env zsh

HISTSIZE=1000000
SAVEHIST=1000000

# Env Variables
source "$ZDOTDIR"/.zshenv

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

function _zvm_config {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_ESCAPE_BINDKEY=^c
    ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
    ZVM_VI_EDITOR=nvim
    ZVM_ESCAPE_KEYTIMEOUT=0.1
}

function _plugin_config {
    _zstyle_completion
    _zvm_config
}

function _init_plugin {

    eval "$(sheldon source)"

    autoload -U compinit
    compinit -d "$ZSH_DATA/.zcompdump"
}

function _init_local {
    source $XDG_CONFIG_HOME/zsh/fn.zsh
    eval "$(pyenv init -)"
    # eval "$(fnm env --use-on-cd)"
    eval "$(zoxide init --cmd j zsh)"
}

function _init_alias {
    # Sane defaults
    alias mv="mv -i"        # confirm before overwriting something
    alias mkdir='mkdir -pv' # Make parent directories and give visual feedback
    alias df='df -h'        # human-readable sizes
    alias free='free -m'    # show sizes in MB

    # Direcotry navigation
    alias l="exa -a --icons --group-directories-first"
    alias ll="exa -a --icons --group-directories-first -l"
    alias pi="nsxiv -a"              # Display image
    alias d="exa -a --icons -D"     # Display only directories
    alias ff="find . -type f -name" # Find file by name in cwd

    # Python programming language
    alias pyrepl="ptpython" # The python REPL interactive shell
    alias pip="python -m pip"
    alias pipx="python3.10 -m pipx"

    # Better utils
    # alias rm="rip"
    # alias cp="cn"

    # R programming language
    alias R="R --quiet" # Run R without the intro
    alias r="radian"    # The better R interactive shell

    # Media playing
    alias audio="pulsemixer"

    # Editor
    alias e="$EDITOR"

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

function _main() {
    _init_local
    _init_options
    eval "$(starship init zsh)"
    _plugin_config
    _init_plugin
    _init_alias
}

_main
