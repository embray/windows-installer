TARGETS=env-runtime cygwin-runtime cygwin-extras-runtime
.PHONY: all $(TARGETS)

############################ Configurable Variables ###########################

# Can be x86 or x86_64
ARCH?=x86_64

# Output paths
DIST?=dist
DOWNLOAD?=download
ENVS?=envs
STAMPS?=.stamps

# Path to the Inno Setup executable
ISCC?=/cygdrive/c/Program Files (x86)/Inno Setup 5/ISCC.exe

################################################################################

# Actual targets for the main build stages (the stamp files)
env-runtime=$(STAMPS)/env-runtime-$(ARCH)
cygwin-runtime=$(STAMPS)/cygwin-runtime-$(ARCH)
cygwin-runtime-extras=$(STAMPS)/cygwin-runtime-extras-$(ARCH)

###############################################################################

# Resource paths
CYGWIN_EXTRAS=cygwin_extras
RESOURCES=resources
ICONS:=$(wildcard $(RESOURCES)/*.bmp) $(wildcard $(RESOURCES)/*.ico)

ENV_RUNTIME_DIR=$(ENVS)/runtime-$(ARCH)

# Files used as input to ISCC
SWC_ISS=SWC.iss
SOURCES:=$(SWC_ISS) $(CYGWIN_EXTRAS) $(ICONS)

# URL to download the Cygwin setup.exe
CYGWIN_SETUP_NAME=setup-$(ARCH).exe
CYGWIN_SETUP=$(DOWNLOAD)/$(CYGWIN_SETUP_NAME)
CYGWIN_SETUP_URL=https://cygwin.com/$(CYGWIN_SETUP_NAME)
CYGWIN_MIRROR=http://mirrors.kernel.org/sourceware/cygwin/

SWC_INSTALLER=$(DIST)/SoftwareCarpentry-$(ARCH).exe

TOOLS=tools
SUBCYG=$(TOOLS)/subcyg

DIRS=$(DIST) $(DOWNLOAD) $(ENVS) $(STAMPS)


################################################################################

all: $(SWC_INSTALLER)

$(SWC_INSTALLER): $(SOURCES) $(env-runtime) | $(DIST)
	cd $(CUDIR)
	"$(ISCC)" /DArch="$(ARCH)" /DEnvsDir="$(ENVS)" /DOutputDir="$(DIST)" \
		$(SWC_ISS)


$(foreach target,$(TARGETS),$(eval $(target): $$($(target))))


$(env-runtime): $(cygwin-runtime) $(cygwin-runtime-extras)
	(cd $(ENV_RUNTIME_DIR) && find . -type l) > $(ENV_RUNTIME_DIR)/etc/symlinks.lst
	@touch $@


$(cygwin-runtime-extras): $(cygwin-runtime)
	cp -r $(CYGWIN_EXTRAS)/* $(ENV_RUNTIME_DIR)
	@touch $@


$(STAMPS)/cygwin-%: $(ENVS)/% | $(STAMPS)
	@touch $@


.SECONDARY: $(ENV_RUNTIME_DIR)
$(ENVS)/%-$(ARCH): cygwin-%.list $(CYGWIN_SETUP)
	"$(CYGWIN_SETUP)" --site $(CYGWIN_MIRROR) \
		--local-package-dir "$$(cygpath -w -a $(DOWNLOAD))" \
		--root "$$(cygpath -w -a $@)" \
		--arch $(ARCH) --no-admin --no-shortcuts --quiet-mode \
		--packages $$($(TOOLS)/setup-package-list $<)


$(CYGWIN_SETUP): | $(DOWNLOAD)
	(cd $(DOWNLOAD) && wget "$(CYGWIN_SETUP_URL)")
	chmod +x $(CYGWIN_SETUP)


$(DIRS):
	mkdir "$@"
