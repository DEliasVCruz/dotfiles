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
