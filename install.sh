#! /bin/bash
set -u

# Directory of this script, so the cp commands work regardless of CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./base-neko-pkgs.sh
base(){

}
niri(){

}
labwc(){

}
xfce(){

}
lxqt(){
}
mate(){
}
kde(){
}

i3(){
}

icejwm(){
}
# desktop-set.sh — copy a desktop's config bundle into the current system.
#
# Usage: ./desktop-set.sh <xfce|niri|kde|mate|labwc|lxqt|icejwm|swayfx>
#
# This script ONLY copies the desktop's config files (etc/ and usr/ trees)
# into the target. Installing the packages and enabling the services is done
# by the installer in C (src/core/rootfs-base.c), NOT here.


apply_desktop_files() {
    local name="$1"
    if [ ! -d "${SCRIPT_DIR}/${name}" ]; then
        echo "ERROR: config bundle for '${name}' not found." >&2
        return 1
    fi
    cp -rfv "${SCRIPT_DIR}/${name}/etc" /
    cp -rfv "${SCRIPT_DIR}/${name}/usr" /
}

# default = the distro's default desktop config (MATE)
case "${1:-}" in
    default ) apply_desktop_files mate || exit 1 ;;
    xfce )   apply_desktop_files xfce   || exit 1 ;;
    kde )    apply_desktop_files kde    || exit 1 ;;
    mate )   apply_desktop_files mate   || exit 1 ;;
    niri )   apply_desktop_files niri   || exit 1 ;;
    lxqt )   apply_desktop_files lxqt   || exit 1 ;;
    icejwm ) apply_desktop_files icejwm || exit 1 ;;
    labwc )  apply_desktop_files labwc  || exit 1 ;;
    i3 )     apply_desktop_files i3     || exit 1 ;;
    swayfx ) apply_desktop_files swayfx || exit 1 ;;
    * )
        echo "Error: Debes especificar un entorno válido."
        echo "Opciones: default, xfce, kde, mate, niri, lxqt, icejwm, labwc, i3, swayfx."
        exit 1
        ;;
esac
