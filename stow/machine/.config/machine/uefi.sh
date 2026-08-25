#!/usr/bin/env bash
set -e

# Only run on UEFI systems
if [[ -d /sys/firmware/efi ]]; then
  echo "Setting systemd-boot timeout to 10s"
  sudo bootctl set-timeout 10
fi

