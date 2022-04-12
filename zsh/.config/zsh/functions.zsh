#!/bin/env zsh

function p() {
	case "$1" in
	*.md) glow -p "$1" ;;
	*.json) fx "$1" ;;
	*) bat "$1" ;;
	esac
}

function tree() {
	command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null
}

function fzg() {
	local result=$(rg --line-number "$@" | fzf) || exit
	local line_num=$(echo "$result" | cut -d':' -f2)
	local file_name=$(echo "$result" | cut -d':' -f1)
	nvim +"$line_num" "$file_name"
}
