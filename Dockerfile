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
    dcron \
    supervisor \
    && rm -rf /var/cache/apk/*

RUN deluser --remove-home node && \
    addgroup -g 1000 docusaurus && \
    adduser -D -u 1000 -G docusaurus docusaurus && \
    mkdir -p /home/docusaurus/cron && \
    chown -R docusaurus:docusaurus /home/docusaurus

ENV TARGET_UID=1000 \
    TARGET_GID=1000 \
    AUTO_UPDATE=true \
    WEBSITE_NAME=MyWebsite \
    TEMPLATE=classic \
    RUN_MODE=development \
    NODE_ENV=development

RUN mkdir -p /docusaurus && \
    chown -R docusaurus:docusaurus /docusaurus

WORKDIR /docusaurus

COPY --chown=docusaurus:docusaurus config/init.sh /
COPY --chown=docusaurus:docusaurus config/auto_update_job.sh /
COPY --chown=docusaurus:docusaurus config/run.sh /
COPY --chown=docusaurus:docusaurus config/supervisord.conf /home/docusaurus/supervisord.conf

RUN chmod +x /init.sh /auto_update_job.sh /run.sh

USER docusaurus

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:80 || exit 1

EXPOSE 80

VOLUME ["/docusaurus"]

ENTRYPOINT ["/init.sh"]