
VERSION = rvex-release-4.0

OUTPUT = rvex-release
CACHE = $(OUTPUT)/cache
TREE = $(OUTPUT)/$(VERSION)
STATUS = $(OUTPUT)/$(VERSION)-status

# Git repository configuration. If you change the repositories, run clean-cache
# first.
RVEX_DIR = .
RVEX_GIT = git@bitbucket.org:jvanstraten/rvex-rewrite.git
RVEX_COMMIT = master
BINUTILS_DIR = tools/binutils-gdb
BINUTILS_BUILD = tools/build
BINUTILS_GIT = git@bitbucket.org:anarcobra/binutils-gdb.git
BINUTILS_COMMIT = master
GCC_DIR = tools/gcc
GCC_BUILD = tools/build
GCC_GIT = git@bitbucket.org:anarcobra/gcc.git
GCC_COMMIT = master
VEXPARSE_DIR = tools/vexparse
VEXPARSE_GIT = git@bitbucket.org:anarcobra/vexparse.git
VEXPARSE_COMMIT = master

# Configuration for other downloads.
HP_VEX_DIR = tools/vex-3.43
HP_VEX_XDIR = tools
HP_VEX_URL = http://www.hpl.hp.com/downloads/vex/vex-3.43.i586.tgz
HP_VEX_FNAME = vex-3.43.i586.tgz

GRLIB_VERSION = grlib-gpl-1.3.7-b4144
GRLIB_DIR = grlib
GRLIB_URL = http://www.gaisler.com/products/grlib/$(GRLIB_VERSION).tar.gz
GRLIB_FNAME = $(GRLIB_VERSION).tar.gz

# List of things which have no online source which need to be copied from the
# working tree:
COPY += tools/sim

# Files to remove from the release:
TRIM_GLOBAL += .git
TRIM_GLOBAL += .gitignore
TRIM_GLOBAL += temp
TRIM += platform/zed-standalone
TRIM += release.makefile

.PHONY: help
help:
	@echo ""
	@echo ""
	@echo ""
	@echo " This makefile is supposed to generate a release tar.gz of the rvex core and"
	@echo " related (redistributable) utilities. This is done using the following command:"
	@echo ""
	@echo "   make release"
	@echo ""
	@echo " The release is generated in '$(OUTPUT)'. The following steps are taken to"
	@echo " generate the release."
	@echo ""
	@echo " First, the following git repositories will be cloned:"
	@echo ""
	@echo "  - $(RVEX_GIT)"
	@echo "     '-> branch/commit: $(RVEX_COMMIT)"
	@echo ""
	@echo "  - $(BINUTILS_GIT)"
	@echo "     '-> branch/commit: $(BINUTILS_COMMIT)"
	@echo ""
	@echo "  - $(GCC_GIT)"
	@echo "     '-> branch/commit: $(GCC_COMMIT)"
	@echo ""
	@echo "  - $(VEXPARSE_GIT)"
	@echo "     '-> branch/commit: $(VEXPARSE_COMMIT)"
	@echo ""
	@echo " The following archive will be downloaded for the HP compiler:"
	@echo ""
	@echo "  - $(HP_VEX_URL)"
	@echo ""
	@echo " The following files/directories will be copied from the working"
	@echo " directory with no modifications:"
	@echo ""
	@for i in $(COPY); do echo "  - $$i"; done
	@echo ""
	@echo " The following files/directories are removed from the release"
	@echo " globally:"
	@echo ""
	@for i in $(TRIM_GLOBAL); do echo "  - $$i"; done
	@echo ""
	@echo " The following files/directories are removed from the release"
	@echo " relative to the root:"
	@echo ""
	@for i in $(TRIM); do echo "  - $$i"; done
	@echo ""

#------------------------------------------------------------------------------
# tar.gz output file generation and release maintenance
#------------------------------------------------------------------------------
.PHONY: release
release: $(OUTPUT)/$(VERSION).tar.gz
$(OUTPUT)/$(VERSION).tar.gz: $(STATUS)/completed
	# <DISABLED> cd $(OUTPUT) && tar -czf $(VERSION).tar.gz $(VERSION)

.PHONY: clean
clean:
	@if [ -d "$(TREE)" ]; then \
		echo ""; \
		printf "\033[1;31m YOU ARE ABOUT TO DELETE ALL INTERMEDIATE FILES/BUILD STATUS FOR \033[0m\n"; \
		printf "\033[1;31m VERSION '$(VERSION)'. ARE YOU SURE? \033[0m\n"; \
		echo ""; \
		rm -rI $(TREE); \
		if [ ! -d "$(TREE)" ]; then \
			rm -rf $(STATUS); \
		else \
			exit 1; \
		fi \
	fi

#------------------------------------------------------------------------------
# Repository and download cache maintenance
#------------------------------------------------------------------------------
.PHONY: clean-cache
clean-cache:
	@echo ""
	@echo " You are about to delete all download cache (git repos, grlib, etc). Sure?"
	@echo ""
	rm -rI $(CACHE);

$(CACHE)/rvex/.git:
	mkdir -p $(CACHE)/rvex
	cd $(CACHE)/rvex && git init
	cd $(CACHE)/rvex && git remote add origin $(RVEX_GIT)

$(CACHE)/binutils/.git:
	mkdir -p $(CACHE)/binutils
	cd $(CACHE)/binutils && git init
	cd $(CACHE)/binutils && git remote add origin $(BINUTILS_GIT)

$(CACHE)/gcc/.git:
	mkdir -p $(CACHE)/gcc
	cd $(CACHE)/gcc && git init
	cd $(CACHE)/gcc && git remote add origin $(GCC_GIT)

$(CACHE)/vexparse/.git:
	mkdir -p $(CACHE)/vexparse
	cd $(CACHE)/vexparse && git init
	cd $(CACHE)/vexparse && git remote add origin $(VEXPARSE_GIT)

$(CACHE)/$(HP_VEX_FNAME):
	mkdir -p $(CACHE)
	cd $(CACHE) && wget $(HP_VEX_URL)

$(CACHE)/$(GRLIB_FNAME):
	mkdir -p $(CACHE)
	cd $(CACHE) && wget $(GRLIB_URL)

#------------------------------------------------------------------------------
# Directory tree initialization (expand)
#------------------------------------------------------------------------------
$(STATUS)/initialized:
	$(MAKE) -f release.makefile clean
	mkdir -p $(TREE)
	mkdir -p $(STATUS)
	touch $@

$(STATUS)/pull-rvex: $(CACHE)/rvex/.git $(STATUS)/initialized
	# <DISABLED> cd $(CACHE)/rvex && git fetch origin $(RVEX_COMMIT)
	mkdir -p $(TREE)/$(RVEX_DIR)
	-rm -f $(TREE)/$(RVEX_DIR)/.git
	ln -s -T $(shell readlink -m $(CACHE)/rvex/.git) $(TREE)/$(RVEX_DIR)/.git
	cd $(TREE)/$(RVEX_DIR) && git reset --hard FETCH_HEAD --
	touch $@

$(STATUS)/pull-binutils: $(CACHE)/binutils/.git $(STATUS)/pull-rvex
	# <DISABLED> cd $(CACHE)/binutils && git fetch origin $(BINUTILS_COMMIT)
	mkdir -p $(TREE)/$(BINUTILS_DIR)
	-rm -f $(TREE)/$(BINUTILS_DIR)/.git
	ln -s -T $(shell readlink -m $(CACHE)/binutils/.git) $(TREE)/$(BINUTILS_DIR)/.git
	cd $(TREE)/$(BINUTILS_DIR) && git reset --hard FETCH_HEAD --
	touch $@

$(STATUS)/pull-gcc: $(CACHE)/gcc/.git $(STATUS)/pull-rvex
	cd $(CACHE)/gcc && git fetch origin $(GCC_COMMIT)
	mkdir -p $(TREE)/$(GCC_DIR)
	-rm -f $(TREE)/$(GCC_DIR)/.git
	ln -s -T $(shell readlink -m $(CACHE)/gcc/.git) $(TREE)/$(GCC_DIR)/.git
	cd $(TREE)/$(GCC_DIR) && git reset --hard FETCH_HEAD --
	touch $@

$(STATUS)/pull-vexparse: $(CACHE)/vexparse/.git $(STATUS)/pull-rvex
	cd $(CACHE)/vexparse && git fetch origin $(VEXPARSE_COMMIT)
	mkdir -p $(TREE)/$(VEXPARSE_DIR)
	-rm -f $(TREE)/$(VEXPARSE_DIR)/.git
	ln -s -T $(shell readlink -m $(CACHE)/vexparse/.git) $(TREE)/$(VEXPARSE_DIR)/.git
	cd $(TREE)/$(VEXPARSE_DIR) && git reset --hard FETCH_HEAD --
	touch $@

$(STATUS)/extract-vex: $(CACHE)/$(HP_VEX_FNAME) $(STATUS)/pull-rvex
	-rm -rf $(TREE)/$(HP_VEX_DIR)
	mkdir -p $(TREE)/$(HP_VEX_XDIR)
	cp $(CACHE)/$(HP_VEX_FNAME) $(TREE)/$(HP_VEX_XDIR)
	cd $(TREE)/$(HP_VEX_XDIR) && tar -xzf $(HP_VEX_FNAME)
	rm -f $(TREE)/$(HP_VEX_XDIR)/$(HP_VEX_FNAME)
	touch $@

$(STATUS)/cache-grlib: $(CACHE)/$(GRLIB_FNAME) $(STATUS)/pull-rvex
	mkdir -p $(TREE)/$(GRLIB_DIR)
	cp $(CACHE)/$(GRLIB_FNAME) $(TREE)/$(GRLIB_DIR)
	touch $@

$(TREE)/%: % $(STATUS)/pull-rvex
	cp -RL $< $(dir $@)

$(STATUS)/copy: $(patsubst %,$(TREE)/%,$(COPY)) $(STATUS)/pull-rvex
	touch $@

$(STATUS)/expand: $(STATUS)/pull-rvex $(STATUS)/pull-binutils $(STATUS)/pull-gcc $(STATUS)/pull-vexparse $(STATUS)/extract-vex $(STATUS)/cache-grlib $(STATUS)/copy
	touch $@

#------------------------------------------------------------------------------
# Toolchain building
#------------------------------------------------------------------------------
$(STATUS)/build-binutils: $(STATUS)/expand
	mkdir -p $(TREE)/$(BINUTILS_BUILD)
	cd $(TREE)/$(BINUTILS_DIR) && ./configure --prefix=$(shell readlink -m $(TREE)/$(BINUTILS_BUILD)) --target=rvex-elf32 --build=i386-unknown-linux-gnu
	cd $(TREE)/$(BINUTILS_DIR) && make
	cd $(TREE)/$(BINUTILS_DIR) && make install
	touch $@

$(STATUS)/build-gcc: $(STATUS)/expand
	mkdir -p $(TREE)/$(GCC_BUILD)
	cd $(TREE)/$(GCC_DIR) && ./configure --prefix=$(shell readlink -m $(TREE)/$(GCC_BUILD)) --target=rvex-elf32 --build=i386-unknown-linux-gnu
	cd $(TREE)/$(GCC_DIR) && make
	cd $(TREE)/$(GCC_DIR) && make install
	touch $@

$(STATUS)/build: $(STATUS)/build-binutils
	touch $@

# MUCH TODO

$(STATUS)/completed: $(STATUS)/build
	touch $(STATUS)/completed
