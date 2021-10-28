# Adds a 'archive' target that will build a zipball of the current git worktree.
#
# ------------------------------------------------------------------------------
#
# Adds a 'archive/%' target that will build an archive of given format
# of the current git worktree. Format can be whatever git-archive supports.
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

.PHONY: archive
# NOTE: we default to zip (instead of tar, git-archive's default)
archive: archive/zip ## Archive source files as a zip file.


.PHONY: archive/%
# NOTE: below is a workaround for 'make help' to work
archive/tar.bz2: ## Archive source files as a tar.bzip2 file.
archive/tar.gz: ## Archive source files as a tar.gz file.
archive/tar.xz: ## Archive source files as a tar.xz file.
archive/tar: ## Archive source files as a tar file.
archive/tgz: ## Archive source files as a tgz file.
archive/zip: ## Archive source files as a zip file.
archive/%:
	$(eval YP_TARBALL_FORMAT := $*)
	if [[ -n "$(GIT_TAGS)" ]]; then \
		YP_TARBALL=archive-$(shell $(GIT) tag --points-at HEAD | $(HEAD) -1); \
	elif [[ -n "$(GIT_BRANCH)" ]]; then \
		YP_TARBALL=archive-$(GIT_BRANCH)-$(GIT_HASH); \
	else \
		YP_TARBALL=archive-$(GIT_HASH); \
	fi; \
	$(ECHO_DO) "Archiving into $${YP_TARBALL}.$(YP_TARBALL_FORMAT)..."; \
	$(YP_DIR)/bin/git-archive-all \
		--format=$(YP_TARBALL_FORMAT) \
		-o $${YP_TARBALL}.$(YP_TARBALL_FORMAT) HEAD; \
	$(ECHO_DONE)
