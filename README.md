# THIS REPO ONLY HAS RICE AND FILES FOR USE ON NEKOVOID DESKTOPS
# Neko Void Desktop Setup

Automated configuration script for desktop environments on Void Linux-based systems. It handles applying global configurations, preparing the user's home directory, and enabling the necessary runit services.

## Usage

```bash
./desktop-set.sh <desktop> <username>

```

## Parameters

| Parameter | Description |
| --- | --- |
| desktop | The name of the desktop environment to install (options: default, xfce, kde, mate, niri, lxqt, icejwm, labwc, i3, swayfx) |
| username | The name of the target user who will receive the configuration files (skel) in their home directory |

## Workflow

1. Verifies the existence of the configuration bundle directory for the specified desktop environment.
2. Copies the system-wide configuration files to the root directory (`/etc` and `/usr`).
3. Copies the base configuration files (`skel`) to the user's home directory and sets the correct ownership permissions.
4. Installs the desktop environment package using the Void Linux package manager (`xbps-install`).
5. Cleans up conflicting network managers and enables core system services via runit.
6. Automatically detects and enables the appropriate Display Manager for the chosen desktop environment.

## Requirements

The script must be executed with superuser (root) privileges to allow system file modifications, ownership changes, and package installation. It also requires the `base-neko-pkgs.sh` file to be present in the same directory.
