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
# Void Linux uses TWO locations for enabled services:
#   1. /var/service/          (active runlevel, managed by runit)
#   2. /etc/runit/runsvdir/default/  (persistent runlevel symlinks)
# We must clean both so the service doesn't respawn after reboot.
# ─────────────────────────────────────────────
disable_sv() {
    local svc="$1"
    # Active runlevel symlink.
    if [ -L "/var/service/${svc}" ]; then
        echo "Disabling service (active): ${svc}"
        rm -f "/var/service/${svc}"
    fi
    # Persistent runlevel default — this is what survives reboots.
    if [ -L "/etc/runit/runsvdir/default/${svc}" ]; then
        echo "Disabling service (default runlevel): ${svc}"
        rm -f "/etc/runit/runsvdir/default/${svc}"
    fi
    # Also clean any direct dir entry (non-symlink) that some ISOs create.
    if [ -e "/etc/runit/runsvdir/default/${svc}" ]; then
        rm -rf "/etc/runit/runsvdir/default/${svc}"
    fi
}

# ─────────────────────────────────────────────
# Remove stale session entries for a desktop. Only removes the *.desktop
# session files we know belong to it, so we don't clobber other desktops.
# ─────────────────────────────────────────────
clean_sessions() {
    local name="$1"
    rm -f "/usr/share/xsessions/${name}.desktop" 2>/dev/null
    rm -f "/usr/share/wayland-sessions/${name}.desktop" 2>/dev/null
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

    # Disable ONLY the DM that belongs to the desktop being removed.
    # (enable_display_manager will clean up the rest when enabling the new one.)
    local old_dm=""
    case "${found}" in
        mate|xfce|lxqt|labwc|icejwm) old_dm="lightdm" ;;
        kde)                          old_dm="sddm"    ;;
        niri)                         old_dm="emptty"  ;;
    esac
    if [ -n "${old_dm}" ]; then
        disable_sv "${old_dm}"
    fi

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
# Enable the chosen display manager's runit service.
#
# Void Linux runit convention:
#   - Services live in /etc/sv/<name>/
#   - Enabling = symlinking into /var/service/  (active, managed by runit)
#   - Persistence across reboots = symlinking into /etc/runit/runsvdir/default/
#
# The ISO ships with lightdm enabled by default; we must remove it from
# both paths before linking the new DM.
# ─────────────────────────────────────────────
enable_display_manager() {
    local dm="$1"

    echo "--- Configuring display manager: ${dm} ---"

    # 1. Disable ALL competing DMs from every known runit location.
    for _dm in lightdm sddm emptty; do
        disable_sv "${_dm}"
    done

    # 2. Verify the service directory exists (package must be installed first).
    if [ ! -d "/etc/sv/${dm}" ]; then
        echo "ERROR: /etc/sv/${dm} not found after package installation!"
        echo "       Check that the package providing '${dm}' is in the package list."
        return 1
    fi

    # 3. Ensure /var/service exists (may be absent in a fresh chroot).
    mkdir -p /var/service

    # 4. Ensure /etc/runit/runsvdir/default exists.
    mkdir -p /etc/runit/runsvdir/default

    # 5. Enable in the active runlevel (/var/service).
    echo "Enabling ${dm} in /var/service/"
    ln -sf "/etc/sv/${dm}" "/var/service/${dm}"

    # 6. Enable in the persistent default runlevel so it survives reboots.
    echo "Enabling ${dm} in /etc/runit/runsvdir/default/"
    ln -sf "/etc/sv/${dm}" "/etc/runit/runsvdir/default/${dm}"

    echo "Display manager '${dm}' enabled successfully."
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
