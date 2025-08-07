#!/bin/bash

# Ensure we're in a clean state
if [[ -n $(git status -s) ]]; then
    echo "❌ Working directory is not clean. Please commit or stash changes first."
    exit 1
fi

# Determine version type
if [ "$1" = "major" ] || [ "$1" = "minor" ] || [ "$1" = "patch" ]; then
    VERSION_TYPE=$1
else
    echo "❌ Please specify version type: major, minor, or patch"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(cat VERSION)
echo "Current version: $CURRENT_VERSION"

# Calculate new version
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
case $VERSION_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update version
echo $NEW_VERSION > VERSION
echo "📝 Updated VERSION to $NEW_VERSION"

# Update changelog
cz changelog
echo "📝 Updated CHANGELOG.md"

# Create release commit
git add VERSION CHANGELOG.md
git commit -m "release: version $NEW_VERSION"

# Create tag
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"

# Push changes
git push origin main
git push origin "v$NEW_VERSION"

echo "✨ Released version $NEW_VERSION"
