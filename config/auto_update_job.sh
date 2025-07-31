#!/usr/bin/env bash

WEB_SRC_PATH="/docusaurus/website"

# Check if website directory exists
if [[ ! -d "$WEB_SRC_PATH" ]]; then
    echo "Website directory $WEB_SRC_PATH does not exist. Skipping update."
    exit 0
fi

if ! cd "$WEB_SRC_PATH"; then
    echo "Cannot enter $WEB_SRC_PATH. Won't run the yarn command to update."
    exit 1
fi

# Check if package.json exists
if [[ ! -f "package.json" ]]; then
    echo "No package.json found in $WEB_SRC_PATH. Skipping update."
    exit 0
fi

echo "Current Docusaurus version:"
if ! yarn docusaurus --version 2>/dev/null; then
    echo "Could not determine current version"
fi

echo "Updating dependencies to latest versions..."

# Create backup of yarn.lock if it exists
if [[ -f "yarn.lock" ]]; then
    if ! cp yarn.lock yarn.lock.backup; then
        echo "Failed to create backup of yarn.lock"
        exit 1
    fi
    echo "Created backup of yarn.lock"
fi

# Update dependencies
if yarn upgrade --latest; then
    echo "Dependencies updated successfully"
    echo "New Docusaurus version:"
    if ! yarn docusaurus --version 2>/dev/null; then
        echo "Could not determine new version"
    fi
else
    upgrade_exit=$?
    echo "Update failed with exit code: $upgrade_exit"
    # Restore backup if update failed
    if [[ -f "yarn.lock.backup" ]]; then
        if mv yarn.lock.backup yarn.lock; then
            echo "Restored yarn.lock from backup"
        else
            echo "Failed to restore yarn.lock from backup"
        fi
    fi
    exit 1
fi

# Clean up backup
if [[ -f "yarn.lock.backup" ]]; then
    rm yarn.lock.backup
fi

echo "Auto-update completed successfully"