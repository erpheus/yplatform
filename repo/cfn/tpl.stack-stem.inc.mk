ENV_NAME ?=

.PHONY: <STACK_STEM>-setup
<STACK_STEM>-setup:
	$(eval STACK_STEM := <STACK_STEM>)
	$(eval STACK_NAME := $(subst env,$(ENV_NAME),$(STACK_STEM))

define <STACK_STEM>-lint
endef

define <STACK_STEM>-pre
endef

define <STACK_STEM>-pre-exec
endef

define <STACK_STEM>-post-exec
endef

define <STACK_STEM>-pre-rm
endef

define <STACK_STEM>-post-rm
endef
