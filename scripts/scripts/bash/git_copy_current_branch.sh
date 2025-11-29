#!/usr/bin/env bash
# This script gets copies the current branch in to the clipboard
# TODO: Make clip command general and read from a env var
#
git branch --show-current | sed 's/^[ \t]*//;s/[ \t]*$//' | clip.exe
