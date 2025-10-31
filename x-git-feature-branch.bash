#!/bin/bash
FEATURE_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for branch in $(git for-each-ref --format='%(refname:short)' refs/remotes/origin/); do
  BASE=$(git merge-base $FEATURE_BRANCH $branch)
  echo "$(git show -s --format='%ci %cr' $BASE)  common with $branch"
done | sort | tail -n 5
