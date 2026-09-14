FROM node:24-bookworm-slim

ARG DSH_VERSION=0.1.5-rc.2

RUN apt-get update \
    && apt-get install --no-install-recommends -y socat \
    && npm install --global "@deepseek-ai/dsh@${DSH_VERSION}" \
    && apt-get purge --auto-remove -y \
    && rm -rf /var/lib/apt/lists/* /root/.npm

COPY docker/patch-opencode-go-session.mjs /opt/dsh/patch-opencode-go-session.mjs

RUN node /opt/dsh/patch-opencode-go-session.mjs \
    && rm /opt/dsh/patch-opencode-go-session.mjs

ENV DSH_HOME=/data/dsh \
    DSH_TELEMETRY_DISABLED=1 \
    HOME=/home/node

RUN mkdir -p /data/dsh /workspace /opt/dsh \
    && chown -R node:node /data/dsh /workspace /opt/dsh

COPY --chown=node:node docker/minimal-network.yml /opt/dsh/minimal-network.yml
COPY --chown=node:node docker/profile-package.json /data/dsh/profiles/web/package.json
COPY --chown=node:node docker/profile-root.yml /data/dsh/profiles/web/cordis.yml
COPY --chown=node:node docker/profile-root.yml /data/dsh/profiles/web/cordis.patch.yml
COPY --chown=node:node docker/entrypoint.sh /opt/dsh/entrypoint.sh

RUN cp /opt/dsh/minimal-network.yml /data/dsh/cordis.patch.yml \
    && chown node:node /data/dsh/cordis.patch.yml \
    && chmod 0555 /opt/dsh/entrypoint.sh

USER node
WORKDIR /workspace

ENTRYPOINT ["/opt/dsh/entrypoint.sh"]
