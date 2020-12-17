ifdef INSTALL_CORE_INC_MK
else

CORE_INC_MK_DIR ?= $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

include $(CORE_INC_MK_DIR)/core.inc.mk
include $(CORE_INC_MK_DIR)/exe.inc.mk
include $(CORE_INC_MK_DIR)/os.inc.mk
include $(CORE_INC_MK_DIR)/git.inc.mk

include $(CORE_INC_MK_DIR)/target.env.inc.mk
include $(CORE_INC_MK_DIR)/target.help.inc.mk
include $(CORE_INC_MK_DIR)/target.noop.inc.mk
include $(CORE_INC_MK_DIR)/target.printvar.inc.mk
include $(CORE_INC_MK_DIR)/target.verbose.inc.mk

MAKEFILE_LAZY ?= true
ifeq (true,$(MAKEFILE_LAZY))
ifeq ($(MAKECMDGOALS),$(filter-out %Makefile.lazy,$(MAKECMDGOALS)))
ifeq (,$(wildcard Makefile.lazy))
$(info [DO  ] Generating Makefile.lazy...)
$(info $(shell $(MAKE) Makefile.lazy))
$(info [DONE])
$(info )
endif
include Makefile.lazy
endif
endif

INSTALL_CORE_INC_MK := 1
endif
