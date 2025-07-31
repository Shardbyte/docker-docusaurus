#!/usr/bin/env bash

WEB_SRC_PATH="/docusaurus/website"

# Change to website directory
if ! cd "$WEB_SRC_PATH"; then
    echo "Cannot enter $WEB_SRC_PATH. Exiting."
    exit 1
fi

echo "Starting Docusaurus in $RUN_MODE mode..."

if [[ "$RUN_MODE" == "development" ]]; then
    echo "Starting development server..."
    exec yarn start --port 80 --host 0.0.0.0
elif [[ "$RUN_MODE" == "production" ]]; then
    echo "Building and serving production build..."
    if ! yarn build; then
        echo "Build failed"
        exit 1
    fi
    exec yarn serve --port 80 --host 0.0.0.0
else
    echo "Unknown run mode '$RUN_MODE'. Trying to run as yarn command..."
    exec yarn run "$RUN_MODE"
fi