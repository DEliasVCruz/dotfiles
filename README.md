# Instalation steps

This is an early prototype of a system install script, the readme is used as a
note taker for now

## Partition your drives

1. Run `lsblk` to see your mounted drives
2. Run `fdisk /dev/sda` to start partitioning
3. Delete partions by passing `d` for as many partions as the drive have
4. Type `n` to make a new partition
5. Configure your **boot** partition by pressing `enter` twice
6. Make it `+1G`, press `Y` for the prompt
7. Configure your **root** partition
8. Make it `+30G` that is usually enough
9. Configure the rest or your partitions (**home** and **swap**)
10. Leave some room of un-used disk space
11. Save your partitons with `w`

## Format partitions

If your bios is an efi system, format a `boot` partion as `mkfs.fat`

```sh
  mkfs.fat -F 32 /dev/sda4
  fatlabel /dev/sda4 BOOT
```

Other wise format your partitions as

```sh
  mkfs.ext4 -L ROOT /dev/sda2
  mkfs.ext4 -L HOME /dev/sda3
  mkfs.ext4 -L BOOT /dev/sda4
  mkswap -L SWAP /dev/sda1
```

## Mount Partitions

You then need to mount your formated partitions

```sh
  swapon /dev/disk/by-label/SWAP
  mount /dev/disk/by-label/ROOT /mnt
  mkdir /mnt/boot
  mkdir /mnt/home
  mount /dev/disk/by-label/HOME /mnt/home
  mount /dev/disk/by-label/BOOT /mnt/boot
```

## Install the base system

Install the base utils for your system to work, along side the respective
package for your init system and a kernel

Also don't forget to generate the `fstab` files and `chroot` to your new system

```sh
  basestrap /mnt base base-devel dinit elogind-dinit
  basestrap /mnt linux-zen linux-firmware
  fstabgen -U /mnt >> /mnt/etc/fstab
  artix-chroot /mnt
```

## Add a user

You need to set the root password and then add some users. Remember to add your
user to the `wheel` group if you want to be able to get `root` privileges

```sh
  passwd
  useradd -G wheel -m daniel
  passwd daniel
```

## Configure the base system

From this point on you may use an installer script

### Configure the system clock and localization

Set the hardware clock to your region and city

```sh
  ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
  hwclock --systohc
  sed -i -r "s/#(en_US.*)/\1/g" /etc/locale.gen
  sed -i -r "s/#(es_PE.*)/\1/g" /etc/locale.gen
  sed -i -r "s/#(ja_JP\.UTF.*)/\1/g" /etc/locale.gen
  locale-gen
  echo 'LANG="en_US.UTF-8"' >/etc/locale.conf
  echo 'LC_COLLATE="C"'
```

### Install a bootloader

You need to install and configure a bootloader

```sh
  pacman -S grub [efibootmgr]
  grub-install --recheck /dev/sda  #BIOS
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub #UEFI
  grub-mkconfig -o /boot/grub/grub.cfg
```

### Configure the network

You need to setup your hostname and install a network manager

```sh
  echo "devc" >/etc/hostname
  printf "127.0.0.1\tlocalhost\n::1\t\t\tlocalhost" >/etc/hosts
  printf "\n127.0.1.1\tdevc.localdomain devc" >>/etc/hosts
  pacman -S connman-dinit
  ln -s ../connmand /etc/dinit.d/boot.d/
```

### Reboot the system

Finally you need to reboot the system

```sh
  exit
  umount -R /mnt
  reboot
```

## After Instalation inform

### Setup repsositories

- Set up the repsositories by editing the `/etc/pacman.conf` file
  - Add the universe repository mirror to this file

```conf
  [universe]
  Server = https://universe.artixlinux.org/$arch
  Server = https://mirror1.artixlinux.org/universe/$arch
  Server = https://mirror.pascalpuffke.de/artix-universe/$arch
  Server = https://artixlinux.qontinuum.space:4443/artixlinux/universe/os/$arch
  Server = https://mirror1.cl.netactuate.com/artix/universe/$arch
```

- Set up the `Ominiverse` repository

- Configure `Artix` mirrors priority by editing the `/etc/pacman.d/mirrorlist` file
- Add support for `Arch` mirrors by installing `artix-archlinux-support` package
  - Enable `extra`, `community` and `multilib`
  - Config a different `Arch` mirror list `/etc/pacman.d/mirrorlist-arch` file
  - Add them to your `/etc/pacman.conf` file
  - Run `pacman-key --populate archlinux`

```conf
# Arch
  [extra]
  Include = /etc/pacman.d/mirrorlist-arch

  [community]
  Include = /etc/pacman.d/mirrorlist-arch

  [multilib]
  Include = /etc/pacman.d/mirrorlist-arch
```

### Configure doas

To configure doas just installed it and then edit the `/etc/doas.conf` file

```sh
# On the /etc/doas.conf file
  permit :wheel
  permit persist :wheel

# On the shell
  sudo chown -c 0400 /etc/doas.conf
```

- You can then use this
  [script](https://github.com/AN3223/scripts/blob/master/doasedit) to emulate
  the `sudoedit` command as `daosedit`

### Install and configure paru

You can install `paru` by installing it from the `AUR` with `yay`, or by
bulding the `makepkg` file

If you are not using `yay` you can't build `makepkg` as a `root` user, so you
either create a new user with no password or use the `nobody` user

1. Install by cloning the packgebuild
2. Configure `paru` in the `paru.conf` file

```sh
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si
```

### Download your repos

- Clone the following directories

  - [st](git@github.com:DEliasVCruz/st.git)
  - [dotfiles](git@github.com:DEliasVCruz/dotfiles.git)

- Create the following directories
  - `.config`
  - `notes`
    - Clone the [repo](git@github.com:DEliasVCruz/ZettlekastenNotes.git)
  - `nvim`
    - Clone the [repo](git@github.com:DEliasVCruz/CristalMoon.git)

### Configure rust

Use `rustup` to install an stable version of `rust`

```sh
  rustup install stable
  rustup default stable
```

Then configure your cargo folder and add it to your `PATH`

```sh
  mkdir -p ~/.cargo/bin
  export PATH="$HOME/.cargo/bin:$PATH"
```

### Configure zsh

Install `sheldon` and `starship` with either the `curl` installer

```sh
  curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

  curl -sS https://starship.rs/install.sh | sh
```

Or with the `cargo` installer

```sh
  cargo install sheldon
  cargo install starship --locked
```

Stow your zsh configuration

### Configure your fonts

You need to link the files from the `/usr/share/fontconfig/conf.avail` folder
to your local `conf.d` folder

- `10-sub-pixel-rgb.conf`
- `50-user.conf`
- `51-local.conf`

### Saving backgrounds

You can save your background images on the `~/.local/share/backgrounds/` folder

### Configure your python

Install and

### Install the window manager

### Configure the wallpaper

### Use full programs

- `tre`: File tree viewer that lets you select a file after
- `herbstluftwm`: The window manager of choosing
  - Already **installed**
- `libqalculate`: A terminal scientific and general porpouse calculator
  - Already **installed**
  - The command is `qalc`
- `conky`
- `setwallpaper`: Go utility to set wallpapers
  - Already **installed**
- `xinfo`: Get detail information about monitors
  - Already **installed**
- `zabb`: Abbreviations for `zoxide` paths
  - Already **installed**
- `rip`: Alternative to rm, the [readme](https://github.com/nivekuil/rip)
  - Already **installed**
- `cn`: Fast memory safe alternative to cp, the [repo](https://gitlab.com/arijit79/cn)
  - Already **installed**
  - Works as drop in replacement
  - Also works as symlink creator
- `rush`: Go alternative to `xargs`, the [repo](https://github.com/shenwei356/rush)
- `handlr`: Rust alternative to `xdg-utils`, the [repo](https://github.com/chmln/handlr)
- `jaro`: A more expressive and customizable alternative to `xdg-open`
  - The [repo](https://github.com/isamert/jaro)
- `rclone`: a command-line program, in go, to sync files and directories to and
  from different cloud storage providers
- `otoclone`: Go based backup utility
  - Depends on `rclone`
- `at`: Like cron but simpler [article](https://linuxhint.com/schedule_linux_task/)
  - Some more [article](https://opensource.com/article/21/7/alternatives-cron-linux)
- `fx`: A commandline viewer for json data
  - The [repo](https://github.com/antonmedv/fx)
  - Needs to be installed through `npm`
- `xorg-setxkbmap`: You can use this to set caps for control
  - Installit with `pacman`
- `dunst`: A notification manager
- `rsmixer`: A rust based pulse auldio mixer controller
  - Already **installed**
- `pulsemixer`: A python based pulse audio mixer
  - Already **installed**
- `pw-audio`: A rust based global audio cli controller
- `picom`: A window compositor for nice window effects
  - Already **installed**
  - The [jonaburg](https://github.com/jonaburg/picom) version of it
- `playerctl`: A comandline tool to control playback of any program
  - Better with a kemapping
  - Already **installed**
- `fontpreview-ueberzug-git`: A previewer of fonts that uses uberzug for
  image preview
  - Already **installed**
- `st-flexipatch`: Dinamically choose the patches for your st
  - The [repo](https://github.com/bakkeby/st-flexipatch/)
- `nbterm`: A jupyter notebook on the terminal
  - The [repo](https://github.com/davidbrochart/nbterm)
  - More on [matplot lib terminal](https://github.com/davidbrochart/nbterm/issues/35)
- `euporie`: A more sofisticated jupyter notebook on the terminal
  - The [repo](https://github.com/joouha/euporie)
- `btop`: A system state and proccess viewer
  - Already **installed**
- `exa`: A modern `ls` replacement written in `rust`
  - Already **installed**
  - Currently used
- `logo-ls`: A replacement for `ls` with nice icons and git statuses
  - Written in `go`
  - Not actively maintained
  - The [repo](https://github.com/Yash-Handa/logo-ls)
- `eg`: A `python` programm to show and create custom examples and cheat sheet
  with markdown
  - The [repo](https://github.com/srsudar/eg)
- `nsxiv`: A feature full yet simple image viewer
  - Already **installed**
  - The [repo](https://github.com/nsxiv/nsxiv)
- `rate-mirrors`: A tool like `reflector` to rate artix and arch mirrors speed
  - Already **installed**
  - The [repo](https://github.com/westandskif/rate-mirrors)
- `pacman-contrib`: Usefull tools for working with a pacman db
  - Contains `paccache`
  - The [repo](https://gitlab.archlinux.org/pacman/pacman-contrib)
- `xidlehook`: An automatic screen locker when your computer is idle
  - Very customizable
  - Written in rust
  - The [repo](https://gitlab.com/jD91mZM2/xidlehook)
- `rsm`: The runit service manager
  - Manage your runit services with ease
  - Already **installed**
  - The [runit cheat sheet](https://stephane-cheatsheets.readthedocs.io/en/latest/init-systems/runit)
  - A [guide](https://docs.voidlinux.org/config/services/index.html) to runit
  - Some missing [runit services](https://github.com/madand/runit-services)
  - The [repo](https://gitea.artixlinux.org/linuxer/Runit-Service-Manager/src/branch/master)

## Misc programs

You can install some of this programs for fun

- `cowsay-bin`: A program that displays a cow
- `c-lolcat`: A program that can colorized the otuput of your terminal
- A [guide](https://www.in-ulm.de/~mascheck/X11/xmodmap.html) on keyboard setup
- `vidir`: Edit file and directory names in your text editor and save changes
- `nincat`: A nice program that displays colored ascii art in your terminal
  - The [repo](https://github.com/ninecath/nincat)

## Posible themes

Her are some nice themes

- `matcha-gtk-theme`: A nice gtk theme
- `arc-icon-theme`: A nice icon theme
