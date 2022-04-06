#!/bin/sh

configure_pacman() {
	echo "Enable Arch repos"
	pacman -Syu --noconfirm artix-archlinux-support
	rm /etc/pacman.d/mirrorlist
	echo "Dowloading LATAM arranged artix mirrorlist"
	curl -o /etc/pacman.d/mirrorlist-artix https://gist.githubusercontent.com/DEliasVCruz/25fbd8309e8dbd6045a810643495a375/raw/603c185ac774599fd1d409846ba13b1781930bd7/mirrorlist-aritx
	curl -o /etc/pacman.conf https://gist.githubusercontent.com/DEliasVCruz/53bed4856f00d6d6a443bd56cb478d7d/raw/e4ab6e8906412465d4794d511f4d2ff0e53c6c12/pacman.conf
	pacman-key --populate archlinux
}

temporal_env() {
	export HOME="/home/daniel/"
	export XDG_DATA_HOME="$HOME/.local/share"
	export CARGO_HOME="$XDG_DATA_HOME/cargo"
	export PATH="$CARGO_HOME/bin:$PATH"
	export PATH="$HOME/scripts:$PATH"
	export PATH="$HOME/bin:$PATH"
	export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
	export PATH="$PYENV_ROOT/bin:$PATH"
	export GOPATH="$XDG_DATA_HOME/go"
	export GOROOT="/usr/local/go"
	export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
}

back_home_from() {
	cd "$HOME" && echo "Exiting $1 dir" || echo 'Could not change directory' && exit
}

user_own() {
	for file in "$@"; do
		chown -R daniel:daniel "$file"
	done
	end
}

clone() {
	for repo in "$@"; do
		git clone git@github.com:DEliasVCruz/"$repo".git
		echo "Cloning $repo repository"
	done
}

setup() {
	echo "Installing setup packages"
	pacman -Syu --noconfirm doas wget dateutils doas git-dinit
	pacman -S --noconfirm stow openssh openssh-dinit
	back_home_from "$(pwd)"
}

create_dir_structure() {
	mkidr ./.config
	mkdir -p ./.cargo/bin
	mkdir ./scripts ./repos ./bin
	mkdir ./Desktop ./Downloads ./Documents
}

clone_main_repos() {
	cd ./repos && echo "Entering repos dir" || exit
	clone CristalMoon st ZettlekastenNotes
	echo "Installing st"
	cd st/ && echo "Enterig st dir" || exit
	git checkout staging
	make clean install && echo "Successfully installed st"
	back_home_from "repos"
}

configure_doas() {
	echo "Installing doas"
	printf "permit :wheel\npermit persist :wheel" >/etc/doas.conf
	chown -c 0400 /etc/doas.conf
}

install_x11_deps() {
	echo "Installing x11 packages"
	pacman -S --noconfirm xorg-server xorg-xinit xorg-xrandr libxrandr libxft
}

install_basic_tools() {
	echo "Installing basic utils"
	pacman -S --noconfirm xsel xclip
	pacman -S --noconfirm man-db man-pages
}

install_paru() {
	echo "Installing paru AUR helper"
	git clone https://aur.archlinux.org/paru.git ~/repos/paru
	cd ./repos/paru && echo "Entering paru dir" || exit
	makepkg -si
	back_home_from "paru"
}

install_fonts() {
	echo "Installing fontconfig"
	pacman -S --noconfirm fontconfig
	echo "Installing fonts"
	pacman -S --noconfirm ttf-font-awesome adobe-source-code-pro-fonts
	pacman -S --noconfirm awesome-terminal-fonts ttf-inconsolata
	pacman -S --noconfirm nerd-fonts-noto-sans-mono nerd-fonts-terminus
}

install_languages() {
	printf "\nInstalling rustup"
	pacman -S --noconfirm rustup
	rustup install stable
	rustup default stable && echo "Installed stable rust"

	printf "\nInstalling go"
	cd /tmp && echo "Entering tmp dir" || exit
	wget https://go.dev/dl/go1.18.linux-amd64.tar.gz
	echo "Extracting files"
	tar -xvf go1.18.linux-amd64.tar.gz && "Successfully extracted"
	echo "Moving go folder"
	mv go /usr/local
	rm -rf go
	go versioin && echo "Installed go" || echo "No go install"

	printf "\nInstalling python"
	git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
	echo "Entering pyenv repo"
	cd $HOME/.pyenv && src/configure && make -C src
	back_home_from "pyenv"
	eval "$(pyenv init --path)" && echo "Successfully initialized pyenv path"
	eval "$(pyenv init -)" && echo "Successfully initialized pyenv"
	pyenv install -v 3.8.0
	pyenv global -v 3.8.0
}

configure_zsh() {
	cargo install sheldon
	cargo install starship --locked
	chsh -s /bin/zsh daniel
}

install_drivers() {
	pacman -S --noconfirm xf86-video-intel xf86-video-nouveau
}

install_basic_programs() {
	pacman -S --noconfirm bat ripgrep fd fzf zsh keepassxc zoxide glow
	pacman -S --noconfirm zathura zathura-djvu zathura-pdf-mupdf zathura-ps
	pacman -S --noconfirm libqalculate unclutter
	go install github.com/xyproto/wallutils/cmd/setwallpaper@latest
	go install github.com/xyproto/wallutils/cmd/xinfo@latest
	cargo install rm-improved
	curl -o $HOME/bin/cn https://gitlab.com/arijit79/cn/uploads/991b176a489f90556c3f2b857f3b974f/cn
	echo "Installing terminals"
	pacman -S --noconfirm kitty alacritty
	echo "Installing browser"
	pacman -S --noconfirm firefox
	update_nvim
}

main() {
	configure_pacman
	temporal_env
	setup
	create_dir_structure
	clone_main_repos
	configure_doas
	install_x11_deps
	install_basic_tools
	install_paru
	install_fonts
	install_languages
	chmod +x ./bin/*
	install_basic_programs
	install_drivers
	configure_zsh
}
