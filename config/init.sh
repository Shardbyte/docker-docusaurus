#!/usr/bin/env bash



find_autoupdate_cron_jobs() {
    local auto_update_jobs=0

    while read -r line; do
        [[ $line == *"auto_update_job"* ]] && (( auto_update_jobs++ ))
    done

    echo $auto_update_jobs
}

DOCU_PATH="/docusaurus"
WEB_SRC_PATH="$DOCU_PATH"/website
AUTO_UPD_CRONTAB_PATH="/auto_update_crontab.txt"

echo -e "Variables:
\\t- AUTO_UPDATE=${AUTO_UPDATE}
\\t- WEBSITE_NAME=${WEBSITE_NAME}
\\t- TEMPLATE=${TEMPLATE}
\\t- RUN_MODE=${RUN_MODE}"

if [[ -z "$WEBSITE_NAME" ]]; then
    echo "You have to enter your website name. Program will be closed."
    exit 1
fi

if [[ "$AUTO_UPDATE" == true ]]; then
    echo "Register a new cron job for auto updating..."
    cat "$AUTO_UPD_CRONTAB_PATH" >> /etc/crontabs/root
    if [[ $(find_autoupdate_cron_jobs < <(crontab -l)) -gt 0 ]]; then
        echo "Successfully registered."
    else
        echo "Register failed with unknown problem. Please issue this on my Github repository."
    fi
fi

if [[ ! -d "$DOCU_PATH"/"$WEBSITE_NAME" ]]; then
    echo "Install docusaurus..."
    if ! npx @docusaurus/init@latest init "$WEBSITE_NAME" "$TEMPLATE"; then
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
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf