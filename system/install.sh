#!/usr/bin/env bash
# System files: copied, never symlinked (root runs them; they must not be user-writable).
#   ./install.sh [diff]   compare repo with live system
#   ./install.sh collect  live system → repo (after editing something in /etc)
#   ./install.sh install  repo → system (only the INSTALL list)
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

# "path mode": safe to install on a fresh install of this machine
INSTALL=(
  "etc/udev/rules.d/90-no-nvme-wakeup.rules 644"
  "etc/sddm.conf.d/10-local.conf 644"
  "etc/grub.d/50_custom 755"
  "usr/lib/systemd/system-sleep/nut-driver-restart 755"
)

mapfile -t TRACKED < <(find . -type f ! -name install.sh -printf '%P\n' | sort)

case ${1:-diff} in
diff)
  for f in "${TRACKED[@]}"; do
    sudo diff -u --label "/$f (live)" --label "$f (repo)" "/$f" "$f" || true
  done ;;
collect)
  for f in "${TRACKED[@]}"; do
    sudo test -e "/$f" || { echo "missing on system: /$f"; continue; }
    sudo cat "/$f" > "$f"
  done
  git status --short . ;;
install)
  backup=/var/backups/dotfiles/$(date +%F_%H%M%S)
  for entry in "${INSTALL[@]}"; do
    read -r f mode <<<"$entry"
    if sudo cmp -s "$f" "/$f"; then echo "unchanged  /$f"; continue; fi
    sudo test -e "/$f" && sudo install -D -m 600 "/$f" "$backup/$f"
    sudo install -D -o root -g root -m "$mode" "$f" "/$f"
    echo "installed  /$f"
  done
  echo "If relevant: sudo grub-mkconfig -o /boot/grub/grub.cfg; sudo udevadm control --reload" ;;
*) echo "usage: $0 [diff|collect|install]" >&2; exit 1 ;;
esac
