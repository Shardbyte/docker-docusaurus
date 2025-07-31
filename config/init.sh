#!/usr/bin/env bash

count_autoupdate_cron_jobs() {
    if [[ -f "/home/docusaurus/cron/crontab" ]]; then
        grep -c "auto_update_job" "/home/docusaurus/cron/crontab" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

DOCU_PATH="/docusaurus"
WEB_SRC_PATH="$DOCU_PATH/website"
USER_CRONTAB_PATH="/home/docusaurus/cron/crontab"

echo "Variables:"
echo -e "\\t- UID=${TARGET_UID}"
echo -e "\\t- GID=${TARGET_GID}"
echo -e "\\t- AUTO_UPDATE=${AUTO_UPDATE}"
echo -e "\\t- WEBSITE_NAME=${WEBSITE_NAME}"
echo -e "\\t- TEMPLATE=${TEMPLATE}"
echo -e "\\t- RUN_MODE=${RUN_MODE}"

if [[ -z "$WEBSITE_NAME" ]]; then
    echo "You have to enter your website name. Program will be closed."
    exit 1
fi

# Setup user cron if auto-update is enabled
if [[ "$AUTO_UPDATE" == "true" ]]; then
    echo "Setting up user cron job for auto updating..."

    # Create user crontab directory
    mkdir -p /home/docusaurus/cron

    # Add existing crontab entries if any
    if crontab -l >/dev/null 2>&1; then
        crontab -l > "$USER_CRONTAB_PATH"
    fi

    # Add auto-update job if not already present
    if ! grep -q "auto_update_job" "$USER_CRONTAB_PATH" 2>/dev/null; then
        echo "0 0 * * * /auto_update_job.sh" >> "$USER_CRONTAB_PATH"
        crontab "$USER_CRONTAB_PATH"

        if [[ $(count_autoupdate_cron_jobs) -gt 0 ]]; then
            echo "Successfully registered auto-update cron job."
        else
            echo "Register failed with unknown problem. Please issue this on Github repository."
        fi
    else
        echo "Auto-update cron job already exists."
    fi
fi

if [[ ! -d "$DOCU_PATH/$WEBSITE_NAME" ]]; then
    echo "Installing Docusaurus..."
    if ! npx @docusaurus/init@latest init "$WEBSITE_NAME" "$TEMPLATE"; then
        echo "Failed to initialize Docusaurus."
        exit 1
    fi
    ln -sf "$DOCU_PATH/$WEBSITE_NAME" "$WEB_SRC_PATH"
else
    echo "Docusaurus configuration already exists in the target directory $DOCU_PATH"
fi

if [[ ! -d "$DOCU_PATH/$WEBSITE_NAME/node_modules" ]]; then
    echo "Installing node modules..."
    if ! (cd "$DOCU_PATH/$WEBSITE_NAME" && yarn install --frozen-lockfile); then
        echo "Failed to install node modules."
        exit 1
    fi
    ln -sf "$DOCU_PATH/$WEBSITE_NAME" "$WEB_SRC_PATH"
else
    echo "Node modules already exist in $DOCU_PATH/$WEBSITE_NAME/node_modules"
fi

if [[ "$RUN_MODE" != "development" && "$RUN_MODE" != "production" ]]; then
    echo "Unsupported mode '$RUN_MODE'. Defaulting to development mode."
    export RUN_MODE="development"
fi

echo "Starting supervisord to start Docusaurus..."
exec supervisord -c /home/docusaurus/supervisord.conf