#!/bin/bash
set -e

BRANCH=$1
TRACKER=$2

if [ -z "$BRANCH" ]; then
  BRANCH="${GITHUB_REF##*/}"
fi

COMMIT_ID=$(git rev-parse HEAD)

if [ ! -f "$TRACKER" ]; then
  echo "{}" > "$TRACKER"
fi

# Get list of changed files in the latest commit
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD)

# If the only change was to the tracker file, skip
if [ "$CHANGED_FILES" = "$TRACKER" ]; then
  echo "Only version tracker changed — skipping tagging"
  echo "skip=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

CURRENT=$(jq -r --arg branch "$BRANCH" '.[$branch].commitId // ""' "$TRACKER")
if [ "$CURRENT" == "$COMMIT_ID" ]; then
  echo "No new commit for $BRANCH; skipping"
  echo "skip=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

VERSION=$(jq -r --arg branch "$BRANCH" '.[$branch].next // 1' "$TRACKER")
TAG="v${VERSION}-${BRANCH}"
git config user.name "github-actions"
git config user.email "actions@github.com"
git tag "$TAG"
git push origin "$TAG"

jq --arg branch "$BRANCH" --arg commitId "$COMMIT_ID" --argjson version "$VERSION" \
  '.[$branch] = {next: ($version + 1), commitId: $commitId}' "$TRACKER" > tmp.json && mv tmp.json "$TRACKER"

git add "$TRACKER"
git commit -m "Update $TRACKER for $BRANCH"
git push

echo "tag=$TAG" >> "$GITHUB_OUTPUT"
echo "skip=false" >> "$GITHUB_OUTPUT"
