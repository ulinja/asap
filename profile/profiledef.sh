#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-asap"
iso_label="ASAPLIVE"
iso_publisher="Ulinja <github.com/ulinja>"
iso_application="Arch Linux Installer"
iso_version="2.0"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
           'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
           'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12' -E ztailpacking)
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.ssh/"]="0:0:600"
  ["/var/lib/iwd/"]="0:0:700"
)
