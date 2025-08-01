#!/usr/bin/env bash

DOCU_PATH="/docusaurus"
WEB_SRC_PATH="$DOCU_PATH"/website

echo -e "Variables:
\\t- AUTO_UPDATE=${AUTO_UPDATE}
\\t- WEBSITE_NAME=${WEBSITE_NAME}
\\t- TEMPLATE=${TEMPLATE}
\\t- RUN_MODE=${RUN_MODE}"

if [[ -z "$WEBSITE_NAME" ]]; then
    echo "You have to enter your website name. Program will be closed."
    exit 1
fi

if [[ ! -d "$DOCU_PATH"/"$WEBSITE_NAME" ]]; then
    echo "Install docusaurus..."
    if ! npx --yes @docusaurus/init@latest init "$WEBSITE_NAME" "$TEMPLATE"; then
        echo "Failed to initialize Docusaurus."
        exit 1
    fi
    ln -sf "$DOCU_PATH"/"$WEBSITE_NAME" "$WEB_SRC_PATH"
else
    echo "Docusaurus configuration already exists in the target directory $DOCU_PATH"
fi

if [[ ! -d "$DOCU_PATH"/"$WEBSITE_NAME"/node_modules ]]; then
    echo "Installing node modules..."
    if ! (cd "$DOCU_PATH"/"$WEBSITE_NAME" && yarn install --frozen-lockfile); then
        echo "Failed to install node modules."
        exit 1
    fi
    ln -sf "$DOCU_PATH"/"$WEBSITE_NAME" "$WEB_SRC_PATH"
else
    echo "Node modules already exist in $DOCU_PATH/$WEBSITE_NAME/node_modules"
fi

if [[ "$RUN_MODE" != "development" && "$RUN_MODE" != "production" ]]; then
    echo "Unsupported mode '$RUN_MODE'. Defaulting to development mode."
    export RUN_MODE="development"
fi

echo "Start supervisord to start Docusaurus..."
exec /run.sh