#!/bin/bash

# Colors definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Get the current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${CYAN}Working with branch ${BOLD}${CURRENT_BRANCH}${NORMAL}${NC}"

# TODO: Check first if it's necessary to push anything
# Get the remote branch it tracks
UPSTREAM_BRANCH=$(git rev-parse --abbrev-ref "${CURRENT_BRANCH}"@\{upstream\} | grep origin)
if [[ "${UPSTREAM_BRANCH}" = "" ]]; then
	echo -e "${CYAN}No remote tracking branch found${NC}"
	echo -e "${GREEN}Remote branch set to track ${BOLD}origin/${CURRENT_BRANCH}${NORMAL}${NC}"

	if git push -u origin "${CURRENT_BRANCH}" >/dev/null 2>&1; then
		echo -e "${GREEN}Branch successfully pushed upstream!${BOLD}${NORMAL}${NC}"

		exit 0
	else
		echo -e "${RED}Something went wrong! ${BOLD}Could not push upstream${NORMAL}${NC}"
		exit 1
	fi
else
	echo -e "${CYAN}Pushing to upstream ${BOLD}${UPSTREAM_BRANCH}${NORMAL}${NC}"
fi

# TODO: Set flag for using the `force` with `getopts`
# Do the normal push
if git push >/dev/null 2>&1; then
	echo -e "${GREEN}Branch successfully pushed upstream!${BOLD}${NORMAL}${NC}"
	exit 0
else
	echo -e "${RED}Something went wrong! ${BOLD}Could not push upstream${NORMAL}${NC}"
	exit 1
fi
