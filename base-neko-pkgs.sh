#!/bin/bash
# ─────────────────────────────────────────────
# Escritorio MATE
# ─────────────────────────────────────────────
MATE_DESKTOP="
    discover
    firefox
    mate
    mate-extra
    mate-tweak
    mate-polkit
    mate-terminal
    mpv
    pluma
    caja-wallpaper
    caja-sendto
    caja-open-terminal
    caja-extensions
    atril
    gnome-screenshot
    gnome-keyring
    gvfs-afc
    gvfs-mtp
    gvfs-smb
    lightdm
    lightdm-webkit2-greeter
    lightdm-gtk-greeter-settings
    libnotify
    numlockx
    picom
    lxappearance
    discover
"
#XFCE DESKTOP
XFCE2="
    xfce4
    xfce4-whiskermenu-plugin
    gnome-themes-standard
    xfce4-pulseaudio-plugin
    xfce4-screenshooter
    atril
    gvfs-afc
    gvfs-mtp
    firefox
    gvfs-smb
    udisks2
    lightdm
    lightdm-webkit2-greeter
    lightdm-gtk-greeter-settings
    libnotify
    numlockx
"
XFCE="
    gnome-software
    xfce4
    xfce4-whiskermenu-plugin
    gnome-themes-standard
    xfce4-pulseaudio-plugin
    xfce4-screenshooter
    atril
    gvfs-afc
    gvfs-mtp
    firefox
    gvfs-smb
    udisks2
    lightdm
    lightdm-webkit2-greeter
    lightdm-gtk-greeter-settings
    libnotify
    numlockx
"
LXQT="
    kate
    discover
    mpv
    lxqt
    xfwm4
    xfwm4-themes
    lightdm
    lightdm-webkit2-greeter
    lightdm-gtk-greeter-settings
    gvfs-afc
    gvfs-mtp
    gvfs-smb
    udisks2
    firefox
    qt6-virtualkeyboard
    qt6-svg
    qt6-multimedia
    gum
"
LXDE="
    lxde
    lightdm
    lightdm-gtk-greeter
    gvfs-afc
    gvfs-mtp
    gvfs-smb
    udisks2
    mpv
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    firefox
"

I3="
    discover
    i3
    lightdm
    xdg-desktop-portal-gtk
    xdg-desktop-portal
    lightdm-gtk-greeter
    polybar
    rofi
    kitty
    geany
    picom
    qt6ct
    lxappearance
    feh
    mpv
    dex
    polkit-gnome 
    pulseaudio-utils
    setxkbmap
    brightnessctl
    playerctl
    maim
    xclip
    xdotool
    pcmanfm
    dmenu
    git
    ark
    curl
    wget
    unzip
    cargo
    pkg-config
    openssl
    libxcb
    xcb-util
    xcb-util-image
    xcb-util-keysyms
    xcb-util-renderutil
    xcb-util-wm
    libxkbcommon
    font-awesome6
    nerd-fonts-symbols-ttf
    fontconfig
    ImageMagick
    libvips
    gvfs-afc
    gvfs-mtp
    gvfs-smb
    udisks2
    firefox
    matugen
    adw-gtk3
    papirus-icon-theme
    lua53
    xsettingsd
    xwinwrap-nk
    ffmpegthumbnailer
    socat
    dunst
    dash
"

ICEJWM="
    discover
    ristretto
    xarchiver
    arandr
    jwm
    jwmkit-neko
    icewm
    mpv
    pcmanfm
    alacritty
    ristretto
    lxappearance
    atril
    lightdm
    lightdm-gtk-greeter
    gvfs-afc
    gvfs-mtp
    gvfs-smb
    udisks2
    firefox
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    mate-polkit
    xfce4-screenshooter
"

KDE="
    kde-plasma
    konsole
    kate
    firefox
    dolphin
    discover
    gvfs-afc
    gvfs-mtp
    gvfs-smb
    mpv
    sddm
    plasma-framework
    kdeconnect
    kdegraphics-thumbnailers
    kde-baseapps
    qt6-virtualkeyboard
    qt6-svg
    qt6-multimedia
    gum
    okular
    spectacle
    gwenview
    ark
"
CINNAMON="
    cinnamon
    gvfs-afc
    gnome-software
    gvfs-mtp
    gvfs-smb
    lightdm
    colord
    gnome-terminal
"

LABWC="
    discover
    ristretto
    xarchiver
	lightdm
	gvfs-afc
    gvfs-mtp
    gvfs-smb
	wlr-randr
	mako
	xwayland-satellite
	swaylock
	mate-polkit
	labwc
	alacritty
	kanshi
	sfwbar
	xdg-desktop-portal
	xdg-desktop-portal-wlr
	playerctl
	rofi
	nwg-look
	gtk-update-icon-cache
	wl-clipboard
	wlopm
	mpv
	ristretto
	geany
	grim
	slurp
	gtksourceview
	json-c
	yad
	waterfox
	gtk-layer-shell
	gtkmm
	pcmanfm
    wlr-randr
    wdisplays
"

NIRI="
    discover
    ristretto
    xarchiver
	gvfs-afc
    gvfs-mtp
    gvfs-smb
    wlr-randr
    wdisplays
	mate-polkit
    caja
    xwayland-satellite
	emptty
	niri
	noctalia
	foot
	xdg-desktop-portal
	xdg-desktop-portal-gnome
	xdg-desktop-portal-wlr
	wl-clipboard
	mako
	wlsunset
	nwg-look
	gtk-update-icon-cache
	wl-clipboard
	wlopm
	mpv
	ristretto
	geany
	grim
	slurp
	gtksourceview
	json-c
	yad
	waterfox
	gtk-layer-shell
	gtkmm
"

# ─────────────────────────────────────────────
# Aplicaciones de escritorio
# ─────────────────────────────────────────────
DESKTOP_APPS="
    gparted
"

# ─────────────────────────────────────────────
# Flatpak + portales
# ─────────────────────────────────────────────
FLATPAK="
    flatpak
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    octoxbps
"

# ─────────────────────────────────────────────
# Fuentes
# ─────────────────────────────────────────────
FONTS="
    noto-fonts-emoji
    noto-fonts-cjk
    noto-fonts-ttf
    font-awesome
    dejavu-fonts-ttf
    liberation-fonts-ttf
    font-misc-misc
    terminus-font
"


MATE=${MATE_DESKTOP}
DEFAULT="
    ${DESKTOP_APPS}
    ${FLATPAK}
    ${FONTS}
"
# ─────────────────────────────────────────────
# Construir la lista completa de paquetes
# ─────────────────────────────────────────────
MATE_PACKAGES="
    ${DEFAULT}
    ${MATE}
"

KDE_PACKAGES="
    ${DEFAULT}
    ${KDE}
"

LXQT_PACKAGES="
    ${DEFAULT}
    ${LXQT}
"
I3_PACKAGES="
    ${DEFAULT}
    ${I3}
"

XFCE_PACKAGES="
    ${DEFAULT}
    ${XFCE}
"

ICEJWM_PACKAGES="
    ${DEFAULT}
    ${ICEJWM}
"

LXDE_PACKAGES="
    ${DEFAULT}
    ${LXDE}
"

CINNAMON_PACKAGES="
    ${DEFAULT}
    ${CINNAMON}
"
LABWC_PACKAGES="
    ${DEFAULT}
    ${LABWC}
"
NIRI_PACKAGES="
    ${DEFAULT}
    ${NIRI}
"
# Limpiar espacios extra y newlines, convertir a una línea
PACKAGES_MATE=$(echo ${MATE_PACKAGES} | tr -s ' ')
PACKAGES_KDE=$(echo ${KDE_PACKAGES} | tr -s ' ')
PACKAGES_LXQT=$(echo ${LXQT_PACKAGES} | tr -s ' ')
PACKAGES_I3=$(echo ${I3_PACKAGES} | tr -s ' ')
PACKAGES_XFCE=$(echo ${XFCE_PACKAGES} | tr -s ' ')
PACKAGES_ICEJWM=$(echo ${ICEJWM_PACKAGES} | tr -s ' ')
PACKAGES_LXDE=$(echo ${LXDE_PACKAGES} | tr -s ' ')
PACKAGES_CINNAMON=$(echo ${CINNAMON_PACKAGES} | tr -s ' ')
PACKAGES_LABWC=$(echo ${LABWC_PACKAGES} | tr -s ' ')
PACKAGES_NIRI=$(echo ${NIRI_PACKAGES} | tr -s ' ')
