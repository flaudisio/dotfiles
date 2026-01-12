#!/usr/bin/env bash

# Configuration to improve the Terragrunt user experience (and fix some issues)

# RECOMMENDATION: use Mise with shim activation!
# https://mise.jdx.dev/dev-tools/shims.html
# eval "$( mise activate bash --shims )"

# If using mise-en-place, ensure specific Terraform versions defined in modules
# are used instead of the version defined in the Infrastructure Live repository
# Ref: https://github.com/jdx/mise/discussions/6174
if command -v mise &> /dev/null ; then
    # https://terragrunt.gruntwork.io/docs/reference/cli/commands/run/#tf-path
    export TG_TF_PATH="${HOME}/.local/share/mise/shims/terraform"
fi

# (DEPRECATED) Avoid a Terragrunt where it reads *ALL* repository HCLs during destroy
# Ref: https://github.com/gruntwork-io/terragrunt/issues/4738#issuecomment-3473372131
# https://terragrunt.gruntwork.io/docs/reference/cli/commands/run/#no-destroy-dependencies-check
# export TG_NO_DESTROY_DEPENDENCIES_CHECK="1"

# Provider cache for improved performance
# Ref: https://terragrunt.gruntwork.io/docs/troubleshooting/performance/#provider-cache
# https://terragrunt.gruntwork.io/docs/reference/cli/commands/run/#provider-cache
export TG_PROVIDER_CACHE="1"

# Fetch dependency outputs from state instead of running 'terraform output' (WAY faster!)
# Ref: https://terragrunt.gruntwork.io/docs/troubleshooting/performance/#fetching-output-from-state
# https://terragrunt.gruntwork.io/docs/reference/cli/commands/run/#dependency-fetch-output-from-state
export TG_DEPENDENCY_FETCH_OUTPUT_FROM_STATE="1"

# Cleaner outputs
# https://terragrunt.gruntwork.io/docs/reference/cli/global-flags/#log-format
# export TG_LOG_FORMAT="bare"

# Even cleaner outputs!
# https://terragrunt.gruntwork.io/docs/reference/cli/commands/run/#tf-forward-stdout
export TG_TF_FORWARD_STDOUT="1"
