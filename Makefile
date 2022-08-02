SHELL := bash
CONFIG := ./asap.conf
WORKING_DIR := /tmp/asapbuild
BUILD_DIR := ./build
PROFILE_DIR := ./profile
CREDENTIALS_DIR := ./credentials

# run a full ASAP ISO build
.PHONY: build
build: build-archiso clean-psk clean-sshkey
	@echo ASAP build completed!

# clean previous builds
.PHONY: clean
clean:
	rm -f $(BUILD_DIR)/*

# runs the archiso image build
.PHONY: build-archiso
build-archiso: clean embed-psk embed-sshkey
	mkdir $(WORKING_DIR)
	mkarchiso -v -w $(WORKING_DIR) -o $(BUILD_DIR) $(PROFILE_DIR)
	rm -rf $(WORKING_DIR)

# embed a WiFi preshared key on the ASAP profile
.PHONY: embed-psk
embed-psk:
	mkdir -p $(PROFILE_DIR)/airootfs/var/lib/iwd
	cp $(CREDENTIALS_DIR)/wpa-preshared-key/* $(PROFILE_DIR)/airootfs/var/lib/iwd/ || exit 0

# removes all WiFi preshared keys from the ASAP profile
.PHONY: clean-psk
clean-psk:
	rm -f $(PROFILE_DIR)/airootfs/var/lib/iwd/*.psk

# embed an authorized SSH public key on the ASAP profile
.PHONY: embed-sshkey
embed-sshkey:
	cat $(CREDENTIALS_DIR)/ssh-public-key/* > $(PROFILE_DIR)/airootfs/root/.ssh/authorized_keys || exit 0

# removes all authorized SSH keys from the ASAP profile
.PHONY: clean-sshkey
clean-sshkey:
	rm -f $(PROFILE_DIR)/airootfs/root/.ssh/authorized_keys
	touch $(PROFILE_DIR)/airootfs/root/.ssh/authorized_keys
