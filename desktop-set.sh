#! /usr/bin/env bash
# desktop-set.sh — install a desktop environment into the current system.
#
# Usage: ./desktop-set.sh <xfce|niri|kde|mate|labwc|lxqt|icejwm>
#
# Designed to run inside the chroot of a freshly copied Void live rootfs.
# It detects which desktop is ALREADY installed (the live image ships with
# one) and removes it before installing the one you selected, so there is no
# desktop conflict and the chosen one actually boots.

set -u
. ./base-neko-pkgs.sh

# Directory of this script, so the cp commands work regardless of CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────
# Repository mirror. xbps-install inside a fresh chroot has no
# /etc/xbps.d config (the installer does not persist it), so we must pass
# --repository explicitly — exactly like the rest of the installer does.
# ─────────────────────────────────────────────
REPO="https://repo-de.voidlinux.org/current/"

# ─────────────────────────────────────────────
# xbps wrappers that always pass --repository + -y, and sync first.
# Without this, xbps-install silently fails because no repository is
# registered in the target chroot.
# ─────────────────────────────────────────────
xpkg_install() {
    echo "Syncing package repositories..."
    xbps-install -S --repository="${REPO}" || {
        echo "ERROR: xbps-install -S failed (no network / DNS?). Aborting." >&2
        return 1
    }
    echo "Installing packages..."
    # shellcheck disable=SC2086  # we WANT word-splitting on the package list
    xbps-install -Sy --repository="${REPO}" $1
}

xpkg_remove() {
    # Don't fail the whole script if some packages are already gone.
    # shellcheck disable=SC2086
    xbps-remove -Ryo --repository="${REPO}" $1 2>/dev/null || true
}

# ─────────────────────────────────────────────
# Disable a runit service if it is currently enabled.
# ─────────────────────────────────────────────
disable_sv() {
    local svc="$1"
    # Remove the "enabled" symlink under /var/service (the active runlevel).
    if [ -L "/var/service/${svc}" ]; then
        echo "Disabling service: ${svc}"
        rm -f "/var/service/${svc}"
    fi
}

# ─────────────────────────────────────────────
# Remove stale session entries for a desktop. Only removes the *.desktop
# session files we know belong to it, so we don't clobber other desktops.
# ─────────────────────────────────────────────
clean_sessions() {
    local name="$1"
    rm -f "/usr/share/xsessions/${name}.desktop" 2>/dev/null
    rm -f "/usr/share/xsessions/*${name}*" 2>/dev/null
    rm -f "/usr/share/wayland-sessions/${name}.desktop" 2>/dev/null
    rm -f "/usr/share/wayland-sessions/*${name}*" 2>/dev/null
}

# ─────────────────────────────────────────────
# Detect which desktop is already installed in this chroot (typically the
# one shipped by the live image) and remove it. Uses xbps-query to check
# package ownership, so it works no matter which DE the image ships.
#
# Each entry maps a signature package to (desktop_name, package_list_var).
# ─────────────────────────────────────────────
installed_pkg() {
    # Returns 0 (true) if the package is installed, 1 otherwise.
    xbps-query "$1" >/dev/null 2>&1
}

remove_existing_desktop() {
    local target="$1"   # the desktop we are about to install (skip if it matches)
    local found=""

    echo "Detecting desktop already installed in this system..."

    # Map signature package -> desktop name. Order matters only for reporting.
    if   installed_pkg mate-desktop-environment 2>/dev/null || installed_pkg mate;      then found="mate"
    elif installed_pkg xfce4;       then found="xfce"
    elif installed_pkg kde-plasma;  then found="kde"
    elif installed_pkg lxqt;        then found="lxqt"
    elif installed_pkg niri;        then found="niri"
    elif installed_pkg labwc;       then found="labwc"
    elif installed_pkg jwm 2>/dev/null || installed_pkg icewm; then found="icejwm"
    fi

    # If we couldn't identify it by signature packages, fall back to session files.
    if [ -z "${found}" ]; then
        for d in mate xfce kde lxqt niri labwc; do
            if ls /usr/share/xsessions/*"${d}"* >/dev/null 2>&1 || \
               ls /usr/share/wayland-sessions/*"${d}"* >/dev/null 2>&1; then
                found="${d}"
                break
            fi
        done
    fi

    if [ -z "${found}" ]; then
        echo "No pre-existing desktop detected — nothing to remove."
        return 0
    fi

    if [ "${found}" = "${target}" ]; then
        echo "Target desktop '${target}' is already installed. Reinstalling/refreshing it."
        return 0
    fi

    echo "Found existing desktop: '${found}'. Removing it..."

    # Disable any display-manager service the old desktop may have enabled,
    # so it doesn't respawn the old session after packages are gone.
    disable_sv lightdm
    disable_sv sddm
    disable_sv emptty

    # Map detected desktop -> package list variable and remove it.
    local pkgs=""
    case "${found}" in
        mate)   pkgs="${PACKAGES_MATE}"   ;;
        xfce)   pkgs="${PACKAGES_XFCE}"   ;;
        kde)    pkgs="${PACKAGES_KDE}"    ;;
        lxqt)   pkgs="${PACKAGES_LXQT}"   ;;
        niri)   pkgs="${PACKAGES_NIRI}"   ;;
        labwc)  pkgs="${PACKAGES_LABWC}"  ;;
        icejwm) pkgs="${PACKAGES_ICEJWM}" ;;
    esac

    if [ -n "${pkgs}" ]; then
        xpkg_remove "${pkgs}"
    fi

    clean_sessions "${found}"
}

# ─────────────────────────────────────────────
# Copy a desktop's config tree (etc/ and usr/) from the bundle into /.
# ─────────────────────────────────────────────
apply_desktop_files() {
    local name="$1"
    cp -rfv "${SCRIPT_DIR}/${name}/etc" /
    cp -rfv "${SCRIPT_DIR}/${name}/usr" /
}

# ─────────────────────────────────────────────
# Enable the chosen display manager's runit service. Uses /etc/sv as the
# canonical service source (Void convention) and links it into /var/service.
# ─────────────────────────────────────────────
enable_display_manager() {
    local dm="$1"
    # Make sure no competing DM is enabled first.
    disable_sv lightdm
    disable_sv sddm
    disable_sv emptty
    if [ -d "/etc/sv/${dm}" ]; then
        echo "Enabling display manager: ${dm}"
        ln -sf "/etc/sv/${dm}" "/var/service/${dm}"
    else
        echo "WARNING: service dir /etc/sv/${dm} not found, cannot enable ${dm}."
    fi
}

# ─────────────────────────────────────────────
# Per-desktop installers
# ─────────────────────────────────────────────
xfce() {
    remove_existing_desktop xfce
    apply_desktop_files xfce
    xpkg_install "${PACKAGES_XFCE}"
    enable_display_manager lightdm
}

niri() {
    remove_existing_desktop niri
    apply_desktop_files niri
    xpkg_install "${PACKAGES_NIRI}"
    enable_display_manager emptty
}

kde() {
    remove_existing_desktop kde
    apply_desktop_files kde
    xpkg_install "${PACKAGES_KDE}"
    enable_display_manager sddm
}

mate() {
    remove_existing_desktop mate
    apply_desktop_files mate
    xpkg_install "${PACKAGES_MATE}"
    enable_display_manager lightdm
}

labwc() {
    remove_existing_desktop labwc
    apply_desktop_files labwc
    xpkg_install "${PACKAGES_LABWC}"
    enable_display_manager lightdm
}

lxqt() {
    remove_existing_desktop lxqt
    apply_desktop_files lxqt
    xpkg_install "${PACKAGES_LXQT}"
    enable_display_manager lightdm
}

icejwm() {
    remove_existing_desktop icejwm
    apply_desktop_files icejwm
    xpkg_install "${PACKAGES_ICEJWM}"
    enable_display_manager lightdm
}

# ─────────────────────────────────────────────
# Dispatcher
# ─────────────────────────────────────────────
case "${1:-}" in
    xfce )   xfce ;;
    kde )    kde ;;
    mate )   mate ;;
    niri )   niri ;;
    lxqt )   lxqt ;;
    icejwm ) icejwm ;;
    labwc )  labwc ;;
    * )
        echo "Error: Debes especificar un entorno válido."
        echo "Opciones: xfce, kde, mate, niri, lxqt, icejwm, labwc."
        exit 1
        ;;
esac
