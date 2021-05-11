SHELL := bash
BUILD_DIR := ./build
SAPLIB_BINARY_DEPS_DIR := $(BUILD_DIR)/dependencies
SETUP_CONFIG := ./saplib.conf

SAPLIB_PACMAN_DEPS := bat exa fish fzf git neovim perl-rename python rsync trash-cli
NVIM_PACMAN_DEPS := clang cmake jdk-openjdk nodejs npm openjdk-doc prettier python-jedi python-pip python-pylint python-pynvim texlive-most yarn
NVIM_NPM_DEPS := bash-language-server neovim node-sql-parser sql-formatter

##### INSTALLATION #####

# install saplib to a new system
.PHONY: install
install: environment bashrc sysinitvim fishconf userinitvim etcskel moduseradd rootshell saplibsrc nvim-pluginstall
	@echo [SUCCESS] Saplib was installed. Please reboot for the changes to take effect.

# updates an existing saplib installation to the newest version
.PHONY: update
update: environment-clean bashrc-clean sysinitvim-clean environment bashrc sysinitvim color pisces saplibsrc etcskel userinitvim nvim-pluginstall
	@echo [SUCCESS] Saplib was updated. Please reboot for the changes to take effect.


##### SAPLIB SYSTEM CHANGES #####

# modify the pacman configuration file
.PHONY: pacmanconf
pacmanconf:
	sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
	sed -i 's/#Color/Color/' /etc/pacman.conf

# install pacman packages needed for saplib
.PHONY: pacmandeps
pacmandeps: pacmanconf
	pacman -Sy --needed --noconfirm $(SAPLIB_PACMAN_DEPS)

# create '/etc/skel' directories
.PHONY: etcskel
etcskel:
	source $(SETUP_CONFIG); for SKELDIR in "$${ETC_SKEL_DIRS[@]}"; do \
			install --directory --group=root --owner=root --mode=755 /etc/skel/$$SKELDIR; done

# modify the useradd defaults to make fish the default login shell
.PHONY: moduseradd
moduseradd: pacmandeps
	sed -i 's/SHELL=\/bin\/bash/SHELL=\/bin\/fish/' /etc/default/useradd

# change root's shell to fish
.PHONY: rootshell
rootshell: pacmandeps
	chsh --shell /bin/fish

# update the 'color' dependency to the latest version
.PHONY: colorupdate
colorupdate: GIT_TMP_DIR := /tmp/git-tmp
colorupdate: OWNER_AND_GROUP := $(shell stat -c '%U:%G' $(SAPLIB_BINARY_DEPS_DIR)/color)
colorupdate: pacmandeps
	rm -rf $(GIT_TMP_DIR) $(SAPLIB_BINARY_DEPS_DIR)/color/*
	git clone 'https://github.com/ali5ter/ansi-color.git' $(GIT_TMP_DIR)
	cp -r $(GIT_TMP_DIR)/ansi-color/* $(SAPLIB_BINARY_DEPS_DIR)/color/
	chown --recursive $(OWNER_AND_GROUP) $(SAPLIB_BINARY_DEPS_DIR)/color/*
	rm -rf $(GIT_TMP_DIR)

# install the color dependency
.PHONY: color
color: colorupdate
	install --group=root --owner=root --mode=755 $(SAPLIB_BINARY_DEPS_DIR)/color/color /usr/local/bin/
	install --group=root --owner=root --mode=644 $(SAPLIB_BINARY_DEPS_DIR)/color/color.1 /usr/share/man/man1/

# update the 'pisces' dependency to the latest version
.PHONY: piscesupdate
piscesupdate: GIT_TMP_DIR := /tmp/git-tmp
piscesupdate: OWNER_AND_GROUP := $(shell stat -c '%U:%G' $(SAPLIB_BINARY_DEPS_DIR)/pisces)
piscesupdate: pacmandeps
	rm -rf $(GIT_TMP_DIR) $(SAPLIB_BINARY_DEPS_DIR)/pisces/*
	git clone 'https://github.com/laughedelic/pisces.git' $(GIT_TMP_DIR)
	cp -r $(GIT_TMP_DIR)/* $(SAPLIB_BINARY_DEPS_DIR)/pisces/
	chown --recursive $(OWNER_AND_GROUP) $(SAPLIB_BINARY_DEPS_DIR)/pisces/*
	rm -rf $(GIT_TMP_DIR)

# install the pisces dependency
.PHONY: pisces
pisces: piscesupdate
	install --group=root --owner=root --mode=644 $(SAPLIB_BINARY_DEPS_DIR)/pisces/conf.d/* /etc/fish/conf.d/
	install --group=root --owner=root --mode=644 $(SAPLIB_BINARY_DEPS_DIR)/pisces/functions/* /etc/fish/functions/

# install the saplib source files
.PHONY: saplibsrc
saplibsrc: color pisces pacmandeps
	rm -rf /usr/local/lib/saplib
	install --directory --group=root --owner=root --mode=755 /usr/local/lib/saplib/bash/src
	install --group=root --owner=root --mode=644 $(BUILD_DIR)/saplib/bash/src/* /usr/local/lib/saplib/bash/src/
	install --group=root --owner=root --mode=644 $(BUILD_DIR)/saplib/bash/saplib.bash /usr/local/lib/saplib/bash/
	install --directory --group=root --owner=root --mode=755 /usr/local/lib/saplib/fish/src
	install --group=root --owner=root --mode=644 $(BUILD_DIR)/saplib/fish/src/* /usr/local/lib/saplib/fish/src/
	install --group=root --owner=root --mode=644 $(BUILD_DIR)/saplib/fish/saplib.fish /usr/local/lib/saplib/fish/
	install --directory --group=root --owner=root --mode=755 /usr/local/lib/saplib/nvim
	install --group=root --owner=root --mode=644 $(BUILD_DIR)/saplib/nvim/* /usr/local/lib/saplib/nvim/

# add saplib variables to the global environment file
.PHONY: environment
environment: saplibsrc
	grep '@SAPLING' /etc/environment 1>/dev/null 2>/dev/null || cat $(BUILD_DIR)/environment.append >> /etc/environment

# remove saplib variables from the global environment file
.PHONY: environment-clean
environment-clean: TARGET_FILE := /etc/environment
environment-clean:
	# check if $(TARGET_FILE) contains start and end tags, move it to $(TARGET_FILE).old if it does
	grep '^#@SAPLING_START$$' $(TARGET_FILE) 1>/dev/null 2>/dev/null && grep '^#@SAPLING_END$$' $(TARGET_FILE) 1>/dev/null 2>/dev/null && \
			mv $(TARGET_FILE) $(TARGET_FILE).old || exit 0
	# copy everything above start tag from $(TARGET_FILE).old to $(TARGET_FILE)
	grep '^#@SAPLING_START$$' $(TARGET_FILE).old 1>/dev/null 2>/dev/null && \
			grep --max-count 1 --before-context 999 '^#@SAPLING_START$$' $(TARGET_FILE).old | head -n -1 > $(TARGET_FILE) || exit 0
	# append everything below end tag from $(TARGET_FILE).old to $(TARGET_FILE)
	grep '^#@SAPLING_END$$' $(TARGET_FILE).old 1>/dev/null 2>/dev/null && \
			grep --max-count 1 --after-context 999 '^#@SAPLING_END$$' $(TARGET_FILE).old | tail -n +2 >> $(TARGET_FILE) || exit 0
	# move $(TARGET_FILE) back to $(TARGET_FILE).old if it has a trailing newline
	tail -n 1 $(TARGET_FILE) | grep '^$$' && mv $(TARGET_FILE) $(TARGET_FILE).old || exit 0
	# remove the trailing newline from $(TARGET_FILE).old and copy contents to $(TARGET_FILE)
	tail -n 1 $(TARGET_FILE).old | grep '^$$' && head -n -1 $(TARGET_FILE).old > $(TARGET_FILE) || exit 0
	# remove $(TARGET_FILE).old
	rm -f $(TARGET_FILE).old

# add saplib variables to the global bashrc
.PHONY: bashrc
bashrc: saplibsrc
	grep '@SAPLING' /etc/bash.bashrc 1>/dev/null 2>/dev/null || cat $(BUILD_DIR)/bash.bashrc.append >> /etc/bash.bashrc

# remove saplib variables from the global bashrc
.PHONY: bashrc-clean
bashrc-clean: TARGET_FILE := /etc/bash.bashrc
bashrc-clean:
	# check if $(TARGET_FILE) contains start and end tags, move it to $(TARGET_FILE).old if it does
	grep '^#@SAPLING_START$$' $(TARGET_FILE) 1>/dev/null 2>/dev/null && grep '^#@SAPLING_END$$' $(TARGET_FILE) 1>/dev/null 2>/dev/null && \
			mv $(TARGET_FILE) $(TARGET_FILE).old || exit 0
	# copy everything above start tag from $(TARGET_FILE).old to $(TARGET_FILE)
	grep '^#@SAPLING_START$$' $(TARGET_FILE).old 1>/dev/null 2>/dev/null && \
			grep --max-count 1 --before-context 999 '^#@SAPLING_START$$' $(TARGET_FILE).old | head -n -1 > $(TARGET_FILE) || exit 0
	# append everything below end tag from $(TARGET_FILE).old to $(TARGET_FILE)
	grep '^#@SAPLING_END$$' $(TARGET_FILE).old 1>/dev/null 2>/dev/null && \
			grep --max-count 1 --after-context 999 '^#@SAPLING_END$$' $(TARGET_FILE).old | tail -n +2 >> $(TARGET_FILE) || exit 0
	# move $(TARGET_FILE) back to $(TARGET_FILE).old if it has a trailing newline
	tail -n 1 $(TARGET_FILE) | grep '^$$' && mv $(TARGET_FILE) $(TARGET_FILE).old || exit 0
	# remove the trailing newline from $(TARGET_FILE).old and copy contents to $(TARGET_FILE)
	tail -n 1 $(TARGET_FILE).old | grep '^$$' && head -n -1 $(TARGET_FILE).old > $(TARGET_FILE) || exit 0
	# remove $(TARGET_FILE).old
	rm -f $(TARGET_FILE).old

# add saplib variables to the global nvim configuration
.PHONY: sysinitvim
sysinitvim: saplibsrc pacmandeps
	install --directory --group=root --owner=root --mode=755 /etc/xdg/nvim/
	grep '@SAPLING' /etc/xdg/nvim/sysinit.vim 1>/dev/null 2>/dev/null || cat $(BUILD_DIR)/sysinit.vim.append >> /etc/xdg/nvim/sysinit.vim

# remove saplib variables from the global nvim configuration
.PHONY: sysinitvim-clean
sysinitvim-clean: TARGET_FILE := /etc/xdg/nvim/sysinit.vim
sysinitvim-clean:
	# check if $(TARGET_FILE) contains start and end tags, move it to $(TARGET_FILE).old if it does
	grep '^"@SAPLING_START$$' $(TARGET_FILE) 1>/dev/null 2>/dev/null && grep '^"@SAPLING_END$$' $(TARGET_FILE) 1>/dev/null 2>/dev/null && \
			mv $(TARGET_FILE) $(TARGET_FILE).old || exit 0
	# copy everything above start tag from $(TARGET_FILE).old to $(TARGET_FILE)
	grep '^"@SAPLING_START$$' $(TARGET_FILE).old 1>/dev/null 2>/dev/null && \
			grep --max-count 1 --before-context 999 '^"@SAPLING_START$$' $(TARGET_FILE).old | head -n -1 > $(TARGET_FILE) || exit 0
	# append everything below end tag from $(TARGET_FILE).old to $(TARGET_FILE)
	grep '^"@SAPLING_END$$' $(TARGET_FILE).old 1>/dev/null 2>/dev/null && \
			grep --max-count 1 --after-context 999 '^"@SAPLING_END$$' $(TARGET_FILE).old | tail -n +2 >> $(TARGET_FILE) || exit 0
	# move $(TARGET_FILE) back to $(TARGET_FILE).old if it has a trailing newline
	tail -n 1 $(TARGET_FILE) | grep '^$$' && mv $(TARGET_FILE) $(TARGET_FILE).old || exit 0
	# remove the trailing newline from $(TARGET_FILE).old and copy contents to $(TARGET_FILE)
	tail -n 1 $(TARGET_FILE).old | grep '^$$' && head -n -1 $(TARGET_FILE).old > $(TARGET_FILE) || exit 0
	# remove $(TARGET_FILE).old
	rm -f $(TARGET_FILE).old

# add saplib to the global fish configuration directory
.PHONY: fishconf
fishconf: saplibsrc pacmandeps
	ln -sf /usr/local/lib/saplib/fish/saplib.fish /etc/fish/conf.d/saplib.fish

# install the saplib neovim user config to '/etc/skel/.config/nvim/init.vim' and '/root/.config/nvim/init.vim'
.PHONY: userinitvim
userinitvim: saplibsrc
	install --directory --group=root --owner=root --mode=755 /etc/skel/.config/nvim
	install --no-target-directory --backup=existing --suffix='.old' --group=root --owner=root --mode=644 \
			$(BUILD_DIR)/init.vim.userdefault /etc/skel/.config/nvim/init.vim
	install --directory --group=root --owner=root --mode=755 /root/.config/nvim
	install --no-target-directory --backup=existing --suffix='.old' --group=root --owner=root --mode=644 \
			$(BUILD_DIR)/init.vim.userdefault /root/.config/nvim/init.vim

##### NEOVIM PLUGINS #####

# install vim-plug for root and in '/etc/skel'
.PHONY: nvim-vimplug
nvim-vimplug: pacmandeps
	curl -fLo "/root/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	curl -fLo "/etc/skel/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install pacman packages needed for saplib neovim
.PHONY: nvim-pacmandeps
nvim-pacmandeps: pacmandeps
	pacman -Sy --needed --noconfirm $(NVIM_PACMAN_DEPS)

# install npm packages needed for saplib neovim
.PHONY: nvim-npmdeps
nvim-npmdeps: nvim-pacmandeps
	npm install --global $(NVIM_NPM_DEPS)

# install the neovim plugins for the root user
.PHONY: nvim-pluginstall
nvim-pluginstall: nvim-vimplug nvim-pacmandeps nvim-npmdeps saplibsrc userinitvim
	nvim -c ":PlugInstall" -c ":qa"
	nvim -c ":CocUpdateSync" -c ":qa"
