#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Xelia - Xtra Scripts Utilities
#
# Shows if a git tags are annotated or lightweight
# ------------------------------------------------------------------------------

source _colors.bash
source _commons.bash
source _settings.bash

x_print_title "Show git tags"

git for-each-ref \
    --format="%(if:equals=tag)%(objecttype)%(then)a %(else)%(if:equals=blob)%(objecttype)%(then)b %(else)  %(end)%(end)%(align:20,right)%(refname:short)%09%(objectname:short)%(end)%09%(if:equals=tag)%(objecttype)%(then)@%(object) %(contents:subject)%(else)%(end)" \
    --sort=taggerdate \
    refs/tags
