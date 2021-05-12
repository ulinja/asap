#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="asap"
iso_version="0.7.0-alpha"
iso_publisher="ulinja <ulinja@pm.me>"
iso_application="ASAP Arch Linux Installer"
iso_label="ASAP_$iso_version"
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.ssh/"]="0:0:600"
  ["/usr/local/bin/asap_check-progress"]="0:0:744"
  ["/usr/local/bin/asap_stage-0"]="0:0:744"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/color"]="0:0:755"
  ["/usr/local/bin/installation-guide"]="0:0:755"
  ["/usr/local/lib/asap/stages/stage0/0-00_asap-init.sh"]="0:0:744"
  ["/var/lib/iwd/"]="0:0:700"
)
