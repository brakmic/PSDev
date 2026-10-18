# syntax=docker/dockerfile:1.7

FROM ubuntu:24.04

ARG PURESCRIPT_VERSION=0.15.16
# SHA-256 digests of the official PureScript release archives. The published
# .sha assets are SHA-1, so the stronger digests are pinned here and updated
# together with PURESCRIPT_VERSION.
ARG PURS_SHA256_AMD64=44da9efb8a4e14519e8fd5350acc377a4b981e42351a78c53e9f84045bf38e22
ARG PURS_SHA256_ARM64=b8d153c5c6e0d8c9618a90824eb342b5818e14a92b0b6cdff753d9b353a927f3
ARG SPAGO_VERSION=1.0.5
ARG PURS_LANGUAGE_SERVER_VERSION=0.18.5
ARG PURS_TIDY_VERSION=0.11.1
ARG PURS_BACKEND_ES_VERSION=1.4.3
ARG ESBUILD_VERSION=0.28.2
ARG NODE_GYP_VERSION=13.1.0
ARG NODE_MAJOR=24
ARG TARGETARCH
ARG USER_NAME=psdev
ARG USER_UID=1000
ARG USER_GID=1000
ARG PSDEV_IMAGE_REVISION=local

LABEL org.opencontainers.image.title="psdev" \
      org.opencontainers.image.description="PureScript development image with Spago, language server, formatter, optimizer, and a C++ build toolchain" \
      org.opencontainers.image.source="https://github.com/brakmic/PSDev" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${PURESCRIPT_VERSION}" \
      org.opencontainers.image.revision="${PSDEV_IMAGE_REVISION}"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    PURESCRIPT_VERSION=${PURESCRIPT_VERSION} \
    SPAGO_VERSION=${SPAGO_VERSION}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        gnupg \
        jq \
        less \
        nano \
        openssh-client \
        pkg-config \
        python3 \
        sudo \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && node --version \
    && npm --version

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) purs_arch=linux64; purs_sha256="${PURS_SHA256_AMD64}" ;; \
        arm64) purs_arch=linux-arm64; purs_sha256="${PURS_SHA256_ARM64}" ;; \
        *) echo "Unsupported architecture for PureScript: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/purescript/purescript/releases/download/v${PURESCRIPT_VERSION}"; \
    curl -fsSL -o /tmp/purs.tar.gz "${base}/${purs_arch}.tar.gz"; \
    actual="$(sha256sum /tmp/purs.tar.gz | cut -d' ' -f1)"; \
    if [ "${purs_sha256}" != "${actual}" ]; then \
        echo "PureScript checksum mismatch: expected ${purs_sha256}, got ${actual}" >&2; \
        exit 1; \
    fi; \
    tar --strip-components=1 -xzf /tmp/purs.tar.gz -C /usr/local/bin purescript/purs; \
    chmod 0755 /usr/local/bin/purs; \
    rm -f /tmp/purs.tar.gz; \
    purs --version

RUN npm install --global --no-fund --no-audit \
        "spago@${SPAGO_VERSION}" \
        "purescript-language-server@${PURS_LANGUAGE_SERVER_VERSION}" \
        "purs-tidy@${PURS_TIDY_VERSION}" \
        "purs-backend-es@${PURS_BACKEND_ES_VERSION}" \
        "esbuild@${ESBUILD_VERSION}" \
        "node-gyp@${NODE_GYP_VERSION}" \
    && npm cache clean --force \
    && spago --version \
    && purs-tidy --version \
    && purs-backend-es --version \
    && esbuild --version

# The base image ships an "ubuntu" user with UID 1000. Replace it so the
# development user owns UID 1000, matching the default user on most hosts.
RUN set -eux; \
    userdel -r ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true; \
    groupadd --gid "${USER_GID}" "${USER_NAME}"; \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USER_NAME}"; \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USER_NAME}"; \
    chmod 0440 "/etc/sudoers.d/${USER_NAME}"; \
    mkdir -p /workspace; \
    chown "${USER_UID}:${USER_GID}" /workspace

USER ${USER_NAME}
WORKDIR /workspace

RUN { \
        echo ''; \
        echo '# PSDev aliases'; \
        echo "alias ll='ls -alF'"; \
        echo "alias sp='spago'"; \
        echo "alias spb='spago build'"; \
        echo "alias spt='spago test'"; \
        echo "alias spr='spago run'"; \
        echo "alias spf='purs-tidy format-in-place src test'"; \
    } >> "${HOME}/.bashrc"

CMD ["/bin/bash"]
