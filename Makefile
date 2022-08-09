SHELL := bash
TMP_DIR := /tmp/asap
WORKING_DIR := $(TMP_DIR)/iso
BUILD_DIR := ./build
PROFILE_DIR := ./profile
CREDENTIALS_DIR := ./credentials

PACKAGE_REPO_DIR := $(PROFILE_DIR)/airootfs/usr/local/lib/aur-packages
PACKAGE_REPO_DB := $(PACKAGE_REPO_DIR)/aur-packages.db.tar.gz
PACKAGE_CACHE_DIR := $(TMP_DIR)/packages/cache

# run a full ASAP ISO build
.PHONY: build
build: build-archiso clean-psk clean-sshkey
	@# make sure all built or modified files are not owned by root
	@chown -R $(shell stat --printf '%U\n' .):$(shell stat --printf '%G\n' .) $(BUILD_DIR) $(PROFILE_DIR)
	@echo ASAP build completed!

# clean previous builds
.PHONY: clean clean-tmp
clean:
	@rm -f $(BUILD_DIR)/*

# clean the working directory
# but abort if bind mounts exist
.PHONY: clean-tmp
clean-tmp:
	@if findmnt | grep $(TMP_DIR) 1>/dev/null; then /bin/false; else /bin/true; fi
	@rm -rf $(TMP_DIR)

# cleans the custom repository directory
.PHONY: clean-repo-dir
clean-repo-dir:
	@rm -rf $(PACKAGE_REPO_DIR)

# fetch and build the AUR packages, and create the custom repository
# FIXME this works but mkarchiso cant find the packages for some reason
.PHONY: prepare-aur-packages
prepare-aur-packages: clean-tmp clean-repo-dir
	@mkdir -p $(PACKAGE_CACHE_DIR)
	@chown -R 1000:1000 $(PACKAGE_CACHE_DIR)

	@sudo -u \#1000 git clone https://aur.archlinux.org/paru.git $(PACKAGE_CACHE_DIR)/paru
	@cd $(PACKAGE_CACHE_DIR)/paru; sudo -u \#1000 makepkg --syncdeps --clean --cleanbuild --force --rmdeps

	@mkdir -p $(PACKAGE_REPO_DIR)
	@repo-add $(PACKAGE_REPO_DB) $(PACKAGE_CACHE_DIR)/paru/*.pkg.tar.zst
	@install --group=1000 --owner=1000 -t $(PACKAGE_REPO_DIR) $(PACKAGE_CACHE_DIR)/paru/*.pkg.tar.zst

# runs the archiso image build
.PHONY: build-archiso
build-archiso: clean embed-psk embed-sshkey #prepare-aur-packages
	@mkdir -p $(WORKING_DIR)
	@mkarchiso -v -w $(WORKING_DIR) -o $(BUILD_DIR) $(PROFILE_DIR)
	@rm -rf $(TMP_DIR)

# embed a WiFi preshared key on the ASAP profile
.PHONY: embed-psk
embed-psk:
	@mkdir -p $(PROFILE_DIR)/airootfs/var/lib/iwd
	@cp $(CREDENTIALS_DIR)/wpa-preshared-key/* $(PROFILE_DIR)/airootfs/var/lib/iwd/ || exit 0

# removes all WiFi preshared keys from the ASAP profile
.PHONY: clean-psk
clean-psk:
	@rm -f $(PROFILE_DIR)/airootfs/var/lib/iwd/*.psk

# embed an authorized SSH public key on the ASAP profile
.PHONY: embed-sshkey
embed-sshkey:
	@cat $(CREDENTIALS_DIR)/ssh-public-key/* > $(PROFILE_DIR)/airootfs/root/.ssh/authorized_keys || exit 0

# removes all authorized SSH keys from the ASAP profile
.PHONY: clean-sshkey
clean-sshkey:
	@rm -f $(PROFILE_DIR)/airootfs/root/.ssh/authorized_keys
	@touch $(PROFILE_DIR)/airootfs/root/.ssh/authorized_keys
