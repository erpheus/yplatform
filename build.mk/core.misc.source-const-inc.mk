# CONST.inc
ifneq (,$(wildcard $(GIT_ROOT)/CONST.inc))
include $(GIT_ROOT)/CONST.inc
export $(shell $(SED) 's/=.\{0,\}//' $(GIT_ROOT)/CONST.inc)
endif

# CONST.inc.secret
ifneq (,$(wildcard $(GIT_ROOT)/CONST.inc.secret))
YP_IS_TRANSCRYPTED ?=
ifeq (true,$(YP_IS_TRANSCRYPTED))

include $(GIT_ROOT)/CONST.inc.secret
export $(shell $(SED) 's/=.\{0,\}//' $(GIT_ROOT)/CONST.inc.secret)

endif
endif
