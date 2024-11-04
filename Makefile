.PHONY: help
help:  ## Show available commands
	@echo "Available commands:"
	@echo
	@sed -n -E -e 's|^([A-Za-z0-9/_-]+):.+## (.+)|\1@\2|p' $(MAKEFILE_LIST) | column -s '@' -t

.PHONY: pre-commit
pre-commit:  ## Run pre-commit (optional: HOOK=example)
	pre-commit run --all-files --verbose --show-diff-on-failure --color always $(HOOK)

.PHONY: .bumpversion
.bumpversion:
	bump-my-version bump $(VERSION_PART)
	@echo
	git show
	@echo
	@echo "Done! Run 'make release' to push the new version to the repository."

.PHONY: bump-version/major
bump-version/major: VERSION_PART=major
bump-version/major: .bumpversion  ## Increment the major version (X.y.z)

.PHONY: bump-version/minor
bump-version/minor: VERSION_PART=minor
bump-version/minor: .bumpversion  ## Increment the minor version (x.Y.z)

.PHONY: bump-version/patch
bump-version/patch: VERSION_PART=patch
bump-version/patch: .bumpversion  ## Increment the patch version (x.y.Z)

.PHONY: release
release:  ## Push the project default branch and its related tags
	git push --follow-tags origin
