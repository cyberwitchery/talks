# netbox with the alembic plugin. the plugin calls the alembic cli and supports
# 0.12, so the image carries that version.
ARG NETBOX_IMAGE=docker.io/netboxcommunity/netbox:v4.6.2
FROM ${NETBOX_IMAGE}

ARG ALEMBIC_VERSION=v0.12.0
ARG NETBOX_ALEMBIC_VERSION=0.3.0
ARG TARGETARCH

USER root
RUN set -eux; \
    case "${TARGETARCH:-arm64}" in \
      amd64) target=x86_64-unknown-linux-gnu ;; \
      arm64) target=aarch64-unknown-linux-gnu ;; \
    esac; \
    name="alembic-${ALEMBIC_VERSION}-${target}"; \
    curl -fsSL "https://github.com/cyberwitchery/alembic/releases/download/${ALEMBIC_VERSION}/${name}.tar.gz" \
      | tar -xz -C /usr/local/bin --strip-components=1 "${name}/alembic"; \
    alembic --version; \
    uv pip install --python /opt/netbox/venv/bin/python "netbox-alembic==${NETBOX_ALEMBIC_VERSION}"; \
    mkdir -p /opt/alembic-work && chown netbox /opt/alembic-work
USER netbox
