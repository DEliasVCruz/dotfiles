#!/bin/bash

base_system() {
	echo "Configuring localization and clock"
	ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
	hwclock --systohc
	sed -i -r "s/#(en_US.*)/\1/g" /etc/locale.gen
	sed -i -r "s/#(es_PE.*)/\1/g" /etc/locale.gen
	sed -i -r "s/#(ja_JP\.UTF.*)/\1/g" /etc/locale.gen
	locale-gen
	echo 'LANG="en_US.UTF-8"' >/etc/locale.conf
	printf '\nLC_COLLATE="C"\n' >>/etc/locale.conf

	echo "Configuring bootloader"
	pacman -S --noconfirm grub      #efibootmgr
	grub-install --recheck /dev/sda #BIOS
	# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub #UEFI
	grub-mkconfig -o /boot/grub/grub.cfg

	echo "Configuring the network"
	echo "devc" >/etc/hostname
	printf "127.0.0.1\tlocalhost\n::1\t\tlocalhost" >/etc/hosts
	printf "\n127.0.1.1\tdevc.localdomain devc\n" >>/etc/hosts
	pacman -S --noconfirm connman-dinit
	ln -s ../connmand /etc/dinit.d/boot.d/
}

configure_pacman() {
	echo "Enable Arch repos"
	pacman -Syu --noconfirm artix-archlinux-support
	rm /etc/pacman.d/mirrorlist
	echo "Dowloading LATAM arranged artix mirrorlist"
	curl -o /etc/pacman.d/mirrorlist-artix https://gist.githubusercontent.com/DEliasVCruz/25fbd8309e8dbd6045a810643495a375/raw/603c185ac774599fd1d409846ba13b1781930bd7/mirrorlist-aritx
	curl -o /etc/pacman.conf https://gist.githubusercontent.com/DEliasVCruz/53bed4856f00d6d6a443bd56cb478d7d/raw/e4ab6e8906412465d4794d511f4d2ff0e53c6c12/pacman.conf
	pacman-key --populate archlinux
}

setup() {
	echo "Installing setup packages"
	pacman -Syu --noconfirm doas wget dateutils doas
	pacman -S --noconfirm stow openssh
	chown -R daniel:daniel /home/daniel/dotfiles
}

configure_doas() {
	echo "Installing doas"
	printf "permit :wheel\npermit persist :wheel\n" >/etc/doas.conf
	printf "permit setenv { XAUTHORITY LANG LC_ALL } :wheel\n\n" >>/etc/doas.conf
	chown -c root:root /etc/doas.conf
	chmod -c 0400 /etc/doas.conf
	pacman -Rns --noconfirm sudo && printf "\nSudo has been removed\n"
	ln -s "$(which doas)" /usr/bin/sudo
}

mid_install_message() {
	printf "Please reboot your machine\n"
	printf "Then re-log on your user account\n"
	printf "Run this script again to continue with the install\n"
}

temporal_env() {
	echo "Continuing with installation as $(whoami)"
	export HOME="/home/daniel"
	export XDG_DATA_HOME="$HOME/.local/share"
	export XDG_CONFIG_HOME="$HOME/.config"
	export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
	export CARGO_HOME="$XDG_DATA_HOME/cargo"
	export PATH="$CARGO_HOME/bin:$PATH"
	export PATH="$HOME/scripts:$PATH"
	export PATH="$HOME/bin:$PATH"
	export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
	export PIPX_HOME="$XDG_DATA_HOME/pipx"
	export PIPX_BIN_DIR="$PIPX_HOME/bin"
	export PATH="$PIPX_BIN_DIR:$PATH"
	export PATH="$PYENV_ROOT/bin:$PATH"
	export GOPATH="$XDG_DATA_HOME/go"
	export DOT="$HOME/dotfiles"
	export ZSH_DATA="$XDG_DATA_HOME/zsh"
	export GOBIN="$GOPATH/bin"
	export GOROOT="/usr/local/go"
	export PATH="$GOBIN:$GOROOT/bin:$PATH"
	export PATH="$HOME/.local/bin:$PATH"
	export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
}

back_home_from() {
	cd "$HOME" && echo "Exiting $1 dir"
}

clone() {
	for repo in "$@"; do
		git clone https://github.com/DEliasVCruz/"$repo".git
		echo "Cloning $repo repository"
	done
}

create_dir_structure() {
	mkdir -p "$HOME"/.config "$XDG_DATA_HOME"/{backgrounds,icons}
	mkdir -p "$CARGO_HOME"/bin "$ZSH_DATA"/completions "$PIPX_BIN_DIR"
	mkdir -p "$HOME"/{scripts,repos,bin}
	mkdir -p "$HOME"/{Downloads,Documents}
}

clone_main_repos() {
	git clone https://github.com/DEliasVCruz/ZettlekastenNotes.git "$HOME"/notes
	mkdir "$HOME"/notes/.zk
	cd $HOME/repos && echo "Entering repos dir"
	clone CristalMoon st
	prinft "Entering dotfiles direcotry"
	cd $DOT && stow -v */ && printf "\nFinish stowing all directories successfully\n"
	back_home_from "dotfiles"
}

install_cargo() {
	printf "\nInstalling rustup\n"
	doas pacman -S --noconfirm rustup
	rustup install stable
	rustup default stable && echo "Installed stable rust"
}

install_paru() {
	echo "Installing paru AUR helper"
	doas pacman -S --noconfirm yay
	yay -S --noconfirm paru-bin

	if [[ $(command -v paru) ]]; then
		echo "paru was successfully installed"
	fi

	doas pacman -Rns --noconfirm yay
	rm -rf "$HOME"/.config/yay
}

install_x11_deps() {
	echo "Installing x11 packages"
	paru -S --noconfirm xorg-server xorg-xinit xorg-xrandr xorg-xset
	paru -S --noconfirm xorg-setxkbmap libxrandr libxft
}

install_basic_tools() {
	echo "Installing basic utils"
	paru -S --noconfirm xsel xclip
	paru -S --noconfirm man-db man-pages
}

install_fonts() {
	echo "Installing fontconfig"
	paru -S --noconfirm fontconfig
	echo "Installing fonts"
	paru -S --noconfirm ttf-nerd-fonts-symbols
	paru -S --noconfirm adobe-source-code-pro-fonts ttf-inconsolata
	paru -S --noconfirm nerd-fonts-noto-sans-mono nerd-fonts-terminus
	paru -S --noconfirm font-victor-mono fontpreview-ueberzug-git
	paru -S --noconfirm helvetica-now ttf-spectral ttf-liberation ttf-croscore
	paru -S --noconfirm noto-fonts-emoji ttf-twemoji-color otf-openmoji
	paru -S --noconfirm ttf-segoe-ui-variable
}

install_languages() {
	printf "\nInstalling go\n"
	cd /tmp && echo "Entering tmp dir"
	wget https://go.dev/dl/go1.18.linux-amd64.tar.gz
	echo "Extracting files"
	tar -xvf go1.18.linux-amd64.tar.gz && echo "Successfully extracted"
	echo "Moving go folder"
	doas mv go /usr/local
	rm -rf go1.18.linux-amd64.tar.gz
	go version && echo "Installed go" || echo "No go install"

	printf "\nInstalling python\n"
	git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT
	echo "Entering pyenv repo"
	cd $PYENV_ROOT && src/configure && make -C src
	back_home_from "pyenv"
	eval "$(pyenv init --path)" && echo "Successfully initialized pyenv path"
	eval "$(pyenv init -)" && echo "Successfully initialized pyenv"

	echo "Installing python 3.10.4"
	pyenv install -v 3.10.4
	echo "Installig more latest python versions"
	pyenv install 3.8.13
	pyenv install 3.9.12
	pyenv install 3.11-dev
	echo "Making python 3.8.13 the global version"
	pyenv global 3.8.13
	command -v python && echo "Successfully installed python"

	echo "Upgrading pip to latest version"
	python -m pip install --upgrade pip && echo "Successfully upgraded pip"
	back_home_from "pyenv"
}

configure_zsh() {
	echo "Installing sheldon"

	echo "Downloading the latest release"
	local tempdir
	tempdir=$(mktemp -d)
	curl -o "$tempdir"/sheldon-0.6.6-x86_64-unknown-linux-musl.tar.gz -L https://github.com/rossmacarthur/sheldon/releases/download/0.6.6/sheldon-0.6.6-x86_64-unknown-linux-musl.tar.gz

	echo "Untaring the files"
	tar -xvf "$tempdir"/sheldon-0.6.6-x86_64-unknown-linux-musl.tar.gz -C "$tempdir" && echo "Successfully untar sheldon files"

	echo "Moving files to path"
	doas mv "$tempdir"/sheldon /usr/bin
	mv "$tempdir"/completions/sheldon.zsh "$ZSH_DATA"/completions/_sheldon && echo "Successfully move sheldon completions files"
	command -v sheldon && echo "Successfully installed sheldon" || echo "Could not install sheldon"

	cargo install starship --locked
	doas chsh -s /bin/zsh daniel
}

install_drivers() {
	paru -S --noconfirm xf86-video-intel xf86-video-nouveau
}

install_audio() {
	paru -S --noconfirm pipewire wireplumber
	paru -S --noconfirm pipewire-pulse pipewire-alsa pipewire-jack
	paru -S --noconfirm rsmixer
}

install_st() {
	echo "Installing st"
	cd "$HOME"/repos/st/ && echo "Enterig st dir"
	git checkout staging
	doas make clean install && echo "Successfully installed st"
	paru -S --noconfirm --removemake libxft-bgra
	back_home_from "st"
}

install_neovim() {
	echo "Begining neovim installation"
	echo "Installing neovim build dependencies"
	paru -S --noconfirm cmake unzip ninja tree-sitter && echo "Successfully installed dependencies"
	echo "Cloning main neovim repo"
	git clone https://github.com/neovim/neovim "$HOME"/repos/neovim
	cd "$HOME"/repos/neovim && echo "Entering neovim repo"
	echo "Building release version"
	make CMAKE_BUILD_TYPE=Release && echo "Successfully build neovim"
	echo "Installing stable neovim"
	paru -S --noconfirm neovim
}

install_basic_programs() {
	paru -S --noconfirm bat ripgrep fd fzf zsh keepassxc zoxide glow
	paru -S --noconfirm zathura zathura-djvu zathura-pdf-mupdf zathura-ps
	paru -S --noconfirm libqalculate unclutter jq playerctl btop sx
	paru -S --noconfirm picom-jonaburg-git herbstluftwm exa nsxiv

	echo "Installing and configuring zk"
	paru -S --noconfirm zk && echo "Successfully installed zk"
	echo "Entering notes directory"
	cd "$HOME"/notes && zk index && "Finished indexing all notes"
	echo "Exiting notes directory"
	back_home_from "notes"

	install_st

	if [ -e /etc/xdg/herbstluftwm/autostart ]; then
		echo "Installing herbstluftwm files"
		cp /etc/xdg/herbstluftwm/autostart "$XDG_DATA_HOME"/herbstluftwm/
		cp /etc/xdg/herbstluftwm/panel.sh "$XDG_DATA_HOME"/herbstluftwm/
		cp /etc/xdg/herbstluftwm/restartpanels.sh "$XDG_DATA_HOME"/herbstluftwm/
		echo "Successfully instaled herbstluftwm files"
	else
		echo "Coudl not install herbstluftwm files"
	fi

	paru -S --noconfirm xwallpaper
	go install github.com/xyproto/wallutils/cmd/xinfo@latest
	paru -S --noconfirm rm-improved
	curl -o $HOME/bin/cn https://gitlab.com/arijit79/cn/uploads/991b176a489f90556c3f2b857f3b974f/cn
	doas chmod +x $HOME/bin/cn
	echo "Installing terminals"
	paru -S --noconfirm kitty
	echo "Installing browser"
	paru -S --noconfirm firefox

	echo "Entering python3.10 for this shell"
	pyenv shell 3.10.4
	echo "Installing pipx"
	python -m pip install --user pipx
	python -m pipx ensurepath

	echo "installing python applications"
	python -m pipx install --python python3.10 ptpython && echo "Successfully installed ptpython"
	python -m pipx install --python python3.10 poetry && echo "Successfully installed poetry"
	poetry completions zsh >"$ZSH_DATA"/completions/_poetry

	install_neovim
}

main() {
	echo "Starting the script"
	if [[ $(whoami) = "root" ]]; then
		base_system
		configure_pacman
		setup
		configure_doas
		mid_install_message
		return 0
	fi
	temporal_env
	create_dir_structure
	clone_main_repos
	install_cargo
	install_paru
	install_x11_deps
	doas pacman -Syu
	install_basic_tools
	install_fonts
	install_languages
	install_basic_programs
	install_audio
	install_drivers
	configure_zsh
}

main
