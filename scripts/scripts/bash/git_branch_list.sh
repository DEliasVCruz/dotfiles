#!/usr/bin/env bash
# This script gets the current branches in the repo and displays
# a prview of the latest commit with diff data, it can also use
# the `ctrl-y` keybinding to copy the name of a branch into the
# clipboard

TRIM_COMMAND="sed 's/^[ \t]*//;s/[ \t]*$//'"

SHOW_COMMAND_OPTIONS='--color=always --word-diff=color --full-diff'
SHOW_COMMAND="git show ${SHOW_COMMAND_OPTIONS} \$(echo {} | ${TRIM_COMMAND})"

# TODO: Make clip command general and read from a env var
COPY_COMMAND="echo {} | ${TRIM_COMMAND} | clip.exe"

# FZF key bidings
FZF_KEY_BINDINGS="ctrl-y:execute[${COPY_COMMAND}]+accept,ctrl-f:preview-page-down,ctrl-b:preview-page-up,ctrl-d:preview-down,ctrl-u:preview-up"

git branch --color -l |
	fzf \
		--ansi \
		--height=50% \
		--preview "${SHOW_COMMAND}" \
		--bind "${FZF_KEY_BINDINGS[@]}"
