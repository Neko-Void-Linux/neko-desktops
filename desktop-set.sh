#! /usr/bin/env bash
# desktop-set.sh — install a desktop environment into the current system.
#
# Usage: ./desktop-set.sh <xfce|niri|kde|mate|labwc|lxqt|icejwm>
#
# Designed to run inside the chroot of a freshly copied Void live rootfs,
# where MATE + lightdm are already installed. When a desktop other than
# MATE is selected we must remove the old display-manager service and the
# stale MATE session entries so the newly installed desktop actually boots.

set -u
. ./base-neko-pkgs.sh

# Directory of this script, so the cp commands work regardless of CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
# Remove stale session entries that the live image carries (MATE by default).
# Only removes the *.desktop session files we know belong to MATE so we don't
# clobber the desktop we are about to install.
# ─────────────────────────────────────────────
clean_mate_sessions() {
    rm -f /usr/share/xsessions/mate.desktop 2>/dev/null
    # gschema-installed helper sessions sometimes reference mate
    rm -f /usr/share/xsessions/*mate* 2>/dev/null
}

# ─────────────────────────────────────────────
# Full teardown of the default MATE desktop shipped with the live image.
# Removes packages, disables the display-manager service and clears session
# entries, so the newly chosen desktop is the one that actually starts.
# ─────────────────────────────────────────────
rm_mate() {
    echo "Removing default MATE desktop from live image..."

    # 1) Disable the live display manager (lightdm/sddm/emptty) so it doesn't
    #    respawn a MATE session after the packages are gone.
    disable_sv lightdm
    disable_sv sddm
    disable_sv emptty

    # 2) Remove MATE packages (-R removes, -o removes orphans, -y assumes yes).
    #    Don't abort the whole script if xbps-remove reports missing packages.
    xbps-remove -Ryo "${PACKAGES_MATE}" 2>/dev/null || true

    # 3) Drop stale MATE session entries.
    clean_mate_sessions
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
# Per-desktop installers
# ─────────────────────────────────────────────
xfce() {
    rm_mate
    apply_desktop_files xfce
    xbps-install -Sy "${PACKAGES_XFCE}"
    enable_display_manager lightdm
}

niri() {
    rm_mate
    apply_desktop_files niri
    xbps-install -Sy "${PACKAGES_NIRI}"
    enable_display_manager emptty
}

kde() {
    rm_mate
    apply_desktop_files kde
    xbps-install -Sy "${PACKAGES_KDE}"
    enable_display_manager sddm
}

mate() {
    apply_desktop_files mate
    xbps-install -Sy "${PACKAGES_MATE}"
    enable_display_manager lightdm
}

labwc() {
    rm_mate
    apply_desktop_files labwc
    xbps-install -Sy "${PACKAGES_LABWC}"
    enable_display_manager lightdm
}

lxqt() {
    rm_mate
    apply_desktop_files lxqt
    xbps-install -Sy "${PACKAGES_LXQT}"
    enable_display_manager lightdm
}

icejwm() {
    rm_mate
    apply_desktop_files icejwm
    xbps-install -Sy "${PACKAGES_ICEJWM}"
    enable_display_manager lightdm
}

# ─────────────────────────────────────────────
# Enable the chosen display manager's runit service. Uses /etc/sv as the
# canonical service source (Void convention) and links it into /var/service.
# ─────────────────────────────────────────────
enable_display_manager() {
    local dm="$1"
    if [ -d "/etc/sv/${dm}" ]; then
        echo "Enabling display manager: ${dm}"
        ln -sf "/etc/sv/${dm}" "/var/service/${dm}"
    else
        echo "WARNING: service dir /etc/sv/${dm} not found, cannot enable ${dm}."
    fi
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
