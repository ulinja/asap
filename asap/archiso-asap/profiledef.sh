#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-sapling"
iso_publisher="Skyforest"
iso_application="Arch Linux Sapling Live/Rescue CD"
iso_version="A-2.2.0"
iso_label="ASAP_$iso_version"
install_dir="arch"
bootmodes=('uefi-x64.systemd-boot.esp')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/environment"]="0:0:644"
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.bashrc"]="0:0:640"
  ["/root/.ssh/"]="0:0:600"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/asap_stage-0"]="0:0:744"
  ["/usr/local/bin/asap_check-progress"]="0:0:744"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/color"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/lib/asap/stages/stage0/0-00_asap-init.sh"]="0:0:744"
  ["/usr/share/man/man1/color.1"]="0:0:644"
  ["/var/lib/iwd/"]="0:0:700"
)
