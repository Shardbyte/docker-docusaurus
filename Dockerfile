#################################################
# Copyright (c) Shardbyte. All Rights Reserved. #
# SPDX-License-Identifier: MIT                  #
#################################################

FROM node:24.4.1-alpine3.22

LABEL   author="Shardbyte" maintainer="containers@shardbyte.com" \
        org.opencontainers.image.source="https://github.com/Shardbyte/docker-docusaurus" \
        org.opencontainers.image.description="Docusaurus container with Node.js based on Alpine Linux" \
        org.opencontainers.image.title="docusaurus" \
        org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache \
    bash \
    curl \
    supervisor \
    && rm -rf /var/cache/apk/*

ENV AUTO_UPDATE=true \
    WEBSITE_NAME=MyWebsite \
    TEMPLATE=classic \
    RUN_MODE=development

RUN mkdir /docusaurus

WORKDIR /docusaurus

COPY config/init.sh /
COPY config/run.sh /
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /init.sh /auto_update_job.sh /run.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:80 || exit 1

EXPOSE 80

VOLUME ["/docusaurus"]

ENTRYPOINT ["/init.sh"]