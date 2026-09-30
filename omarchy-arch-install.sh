#!/usr/bin/env bash
# Install Omarchy on a bare Arch Linux host (e.g. Vultr Arch instance).
# Run as root or a sudo-capable user:  bash omarchy-arch-install.sh
set -euo pipefail

[[ -e /etc/arch-release ]] || { echo "This is not Arch Linux" >&2; exit 1; }

pacman -Sy --noconfirm --needed git curl sudo

# Omarchy's installer wants a non-root sudo user; make one if we're root.
if [[ $EUID -eq 0 ]] && ! id omarchy &>/dev/null; then
  useradd -m -G wheel -s /bin/bash omarchy
  echo 'omarchy ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/omarchy
  # hand over the SSH keys so you can actually log in as omarchy
  mkdir -p /home/omarchy/.ssh
  [[ -f /root/.ssh/authorized_keys ]] && cp /root/.ssh/authorized_keys /home/omarchy/.ssh/
  chown -R omarchy:omarchy /home/omarchy/.ssh
fi

# Cloud VMs have no GPU; let Hyprland come up headless instead of crashing.
if ! ls /dev/dri/* &>/dev/null; then
  export WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1
fi

if id omarchy &>/dev/null && [[ $EUID -eq 0 ]]; then
  sudo -u omarchy -i env "WLR_BACKENDS=$WLR_BACKENDS" "WLR_LIBINPUT_NO_DEVICES=$WLR_LIBINPUT_NO_DEVICES" \
    bash -c 'curl -fsSL https://omarchy.org/install | bash'
else
  bash -c 'curl -fsSL https://omarchy.org/install | bash'
fi
