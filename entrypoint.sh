#!/bin/bash
set -e

TRACKER=${1:-version.json}

if [ ! -f "$TRACKER" ]; then 
  echo "Tracker file not found: $TRACKER"
  exit 1 
fi

# get list of changed files in the latest commit
CHANGED_FILES=$(git diff --name-only HEAD^ HEAD)

echo "🔍 TRACKER: [$TRACKER]"
echo "🔍 CHANGED_FILES:"
echo "$CHANGED_FILES" | sed 's/^/ - /'

CHANGED_COUNT=$(echo "$CHANGED_FILES" | wc -l)
COMMIT_ID=$(git rev-parse HEAD)
LAST_COMMIT=$(jq -r '.commitId // ""' "$TRACKER")

# CASE: commit ID hasn't changed
if [ "$COMMIT_ID" == "$LAST_COMMIT" ]; then 
  echo "Commit unchanged, skipping version bump"
  echo "" > tag.txt
  echo "true" > skip.txt
  echo "skip=true" >> "$GITHUB_OUTPUT"
  echo "tag=" >> "$GITHUB_OUTPUT"
  exit 0
fi

# CASE: only tracker file was modified
if [ "$CHANGED_COUNT" -eq 1 ] && [ "$CHANGED_FILES" = "$TRACKER" ]; then
  echo "Only $TRACKER was changed — skipping version tag"
  echo "" > tag.txt
  echo "true" > skip.txt
  echo "skip=true" >> "$GITHUB_OUTPUT"
  echo "tag=" >> "$GITHUB_OUTPUT"
  exit 0
else
  echo "Continuing — other files changed or multiple files"
fi

# tag repo with version number
VERSION=$(jq -r '.next // 1' "$TRACKER")
TAG="v${VERSION}"
OUTPUT_PATHS=$(jq -r '.outputPaths[]' "$TRACKER")

echo "Tagging as $TAG"
git config user.name "github-actions"
git config user.email "actions@github.com"
git tag "$TAG"
git push origin "$TAG"

# write version.txt to each output path
for path in $OUTPUT_PATHS; do 
  echo "Writing version to $path/version.txt"
  mkdir -p "$path"
  echo "$TAG" > "$path/version.txt"
  git add "$path/version.txt"
done

# update version tracker
jq --arg commitId "$COMMIT_ID" --argjson version "$VERSION" \
  '.next = ($version + 1) | .commitId = $commitId' "$TRACKER" > tmp.json && mv tmp.json "$TRACKER"
git add "$TRACKER"
git commit -m "Update $TRACKER"
git push

# set outputs for GitHub Actions
echo "tag=$TAG" >> "$GITHUB_OUTPUT"
echo "skip=false" >> "$GITHUB_OUTPUT"

# also echo to temp file to grab in composite action
echo "$TAG" > tag.txt
echo "false" > skip.txt
