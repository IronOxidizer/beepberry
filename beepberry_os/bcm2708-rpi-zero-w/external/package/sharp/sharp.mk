SHARP_VERSION = 56fc25d3cc0d8d32065b6e54f3901378a1b83dea
SHARP_SITE = https://github.com/w4ilun/Sharp-Memory-LCD-Kernel-Driver/archive
SHARP_SOURCE = $(SHARP_VERSION).tar.gz

define SHARP_BUILD_CMDS
    $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) all
endef

define SHARP_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 644 $(@D)/sharp.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VERSION)/extra/
endef

$(eval $(generic-package))
