#!/usr/bin/env bash

# OpenCode silently caps per-step maxOutputTokens at 32,000 even when opencode.json sets a much larger 'limit.output'
# Ref: https://github.com/anomalyco/opencode/issues/29363
export OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=384000
