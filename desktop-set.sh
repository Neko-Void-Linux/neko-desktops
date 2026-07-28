#! /usr/bin/env bash
. ./base-neko-pkgs.sh
rm_mate(){
xbps-remove -Ro $PACKAGES_MATE
}
xfce(){
    rm_mate
    cp -rfv xfce/etc /
    cp -rfv xfce/usr /
    xbps-install -Sy $PACKAGES_XFCE
}

niri(){
    rm_mate
    cp -rfv niri/etc /
    cp -rfv niri/usr /
    xbps-install -Sy $PACKAGES_NIRI
}

kde(){
    rm_mate
    cp -rfv kde/etc /
    cp -rfv kde/usr /
    xbps-install -Sy $PACKAGES_KDE
}

mate(){
    cp -rfv mate/etc /
    cp -rfv mate/usr /
    xbps-install -Sy $PACKAGES_MATE
}

labwc(){
    rm_mate
    cp -rfv labwc/etc /
    cp -rfv labwc/usr /
    xbps-install -Sy $PACKAGES_LABWC
}

lxqt(){
    rm_mate
    cp -rfv lxqt/etc /
    cp -rfv lxqt/usr /
    xbps-install -Sy $PACKAGES_LXQT
}

icejwm(){
    rm_mate
    cp -rfv icejwm/etc /
    cp -rfv icejwm/usr /
    xbps-install -Sy $PACKAGES_ICEJWM
}

case "$1" in
    xfce ) xfce ;;
    kde ) kde ;;
    mate ) mate ;;
    niri ) niri ;;
    lxqt ) lxqt ;;
    icejwm ) icejwm ;;
    labwc ) labwc ;;
    * )
        echo "Error: Debes especificar un entorno válido."
        echo "Opciones: xfce, kde, mate, niri, lxqt, icejwm, labwc."
        exit 1
        ;;
esac
