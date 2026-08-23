#! /bin/bash
set -u

# Directory of this script, so the cp commands work regardless of CWD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ./base-neko-pkgs.sh

# desktop-set.sh — copy a desktop's config bundle into the current system and enable services.
#
# Usage: ./desktop-set.sh <desktop_name> <username>

# Extrae y habilita los servicios base del sistema
enable_base_services() {
    echo "Configurando servicios base..."
    
    # Evitar conflictos de red eliminando gestores antiguos si existen
    rm -rf /var/service/dhcpcd
    rm -rf /var/service/wpa_supplicant

    # Habilitar servicios comunes
    local services=(
        "NetworkManager"
        "dbus"
        "chronyd"
        "power-profiles-daemon"
        "polkitd"
        "bluetoothd" # Extraído también de la función bluetooth original
    )

    for sv in "${services[@]}"; do
        if [ -d "/etc/sv/$sv" ]; then
            ln -sf "/etc/sv/$sv" "/var/service/"
            echo " -> Servicio $sv habilitado."
        fi
    done
}

# Habilita el gestor de sesión (Display Manager) según el entorno
enable_dm_service() {
    local desktop="$1"
    local dm=""

    case "$desktop" in
        gnome)              dm="gdm" ;;
        kde|lxqt)           dm="sddm" ;;
        xfce|mate|icejwm)   dm="lightdm" ;;
        # niri, labwc, i3, swayfx suelen usarse desde TTY, greetd o ly. 
        # Si usas un DM para ellos, agrégalo aquí.
    esac

    if [ -n "$dm" ]; then
        if [ -d "/etc/sv/$dm" ]; then
            ln -sf "/etc/sv/$dm" "/var/service/"
            echo " -> Display Manager $dm habilitado."
        else
            echo "ADVERTENCIA: El servicio /etc/sv/$dm no existe. ¿Está instalado el paquete?" >&2
        fi
    fi
}

apply_desktop_files() {
    local name="$1"
    local target_user="$2" 
    local target_home="/home/${target_user}"

    if [ ! -d "${SCRIPT_DIR}/${name}" ]; then
        echo "ERROR: config bundle for '${name}' not found." >&2
        return 1
    fi
    
    if [ -z "$target_user" ]; then
        echo "ERROR: target user not specified." >&2
        return 1
    fi

    # 1. Copiar configuraciones del sistema (requiere root)
    cp -rfv "${SCRIPT_DIR}/${name}/etc" /
    cp -rfv "${SCRIPT_DIR}/${name}/usr" /

    # 2. Copiar el skeleton al home del usuario real
    cp -rfv "${SCRIPT_DIR}/${name}/etc/skel/." "${target_home}/"

    # 3. Arreglar los permisos para que el usuario sea el dueño de sus archivos
    chown -R "${target_user}:${target_user}" "${target_home}/"

    # 4. Instalar el paquete de Void Linux de forma segura
    xbps-install -Sy "${pkg}-${name}"

    # 5. Habilitar servicios base y el Display Manager
    enable_base_services
    enable_dm_service "$name"
}

# Obtener los argumentos de forma segura
DESKTOP_CHOICE="${1:-}"
TARGET_USER="${2:-}"

# Si el usuario no especificó el TARGET_USER, le avisamos antes de fallar
if [ -z "$TARGET_USER" ]; then
    echo "Uso: $0 <entorno> <usuario>"
    echo "Ejemplo: $0 niri franckey"
    exit 1
fi

case "$DESKTOP_CHOICE" in
    default ) apply_desktop_files mate "$TARGET_USER" || exit 1 ;;
    xfce )    apply_desktop_files xfce "$TARGET_USER"   || exit 1 ;;
    kde )     apply_desktop_files kde "$TARGET_USER"    || exit 1 ;;
    mate )    apply_desktop_files mate "$TARGET_USER"   || exit 1 ;;
    niri )    apply_desktop_files niri "$TARGET_USER"   || exit 1 ;;
    lxqt )    apply_desktop_files lxqt "$TARGET_USER"   || exit 1 ;;
    icejwm )  apply_desktop_files icejwm "$TARGET_USER" || exit 1 ;;
    labwc )   apply_desktop_files labwc "$TARGET_USER"  || exit 1 ;;
    i3 )      apply_desktop_files i3 "$TARGET_USER"     || exit 1 ;;
    swayfx )  apply_desktop_files swayfx "$TARGET_USER" || exit 1 ;;
    * )
        echo "Error: Debes especificar un entorno válido."
        echo "Opciones: default, xfce, kde, mate, niri, lxqt, icejwm, labwc, i3, swayfx."
        exit 1
        ;;
esac
