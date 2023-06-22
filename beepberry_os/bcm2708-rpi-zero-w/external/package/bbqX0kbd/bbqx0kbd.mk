BBQX0KBD_VERSION = 802b73fe13858c89fd73ef9e536aff2267a6ae20
BBQX0KBD_SITE = https://github.com/sqfmi/bbqX0kbd_driver/archive
BBQX0KBD_SOURCE = $(BBQX0KBD_VERSION).tar.gz

define BBQX0KBD_BUILD_CMDS
    $(@D)/installer.sh --BBQ20KBD_TRACKPAD_USE BBQ20KBD_TRACKPAD_AS_KEYS --BBQX0KBD_INT BBQX0KBD_USE_INT
endef

define BBQX0KBD_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 644 $(@D)/bbqX0kbd.ko $(TARGET_DIR)/lib/modules/$(KERNEL_VERSION)/kernel/drivers/i2c/
endef

$(eval $(generic-package))
