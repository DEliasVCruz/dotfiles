#!/usr/bin/env bash
# This is a personally modifed version of the script provided by Shawn McElroy for Space Rock Media
# You can find the original article on https://dev.to/spacerockmedia/how-i-manage-my-dotfiles-using-gnu-stow-4l59

# make sure we have pulled in and updated any submodules
git submodule init
git submodule update

# what directories should be installable by all users including the root user
base=(
	zsh
	git
	bin
	alacritty
	fontconfig
	bat
	glow
	keepassxc
	kitty
	paru
	ptpython
	sheldon
	x11
	zathura
	zsh
	neovim
	wallpapers
	picom
)

# run the stow command for the passed in directory ($2) in location $1
stowit() {
	usr=$1
	app=$2
	stow -v -R -t "${usr}" "${app}"
}

echo ""
echo "Stowing apps"

# install apps available to local users and root
for app in "${base[@]}"; do
	stowit "${HOME}" "$app"
done

echo ""
echo "##### ALL DONE"
