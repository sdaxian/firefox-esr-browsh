# syntax=docker/dockerfile:1.4

# Define some mirror for speed, such as mirrors.ustc.edu.cn  .
ARG PACKAGE_MIRRORS_HOST
ARG ALPINE_GLIBC_USE_GCOMPAT
ARG GITHUB_FILE_MIRRORS_HOST

# For the packages mirrors .
ARG RUN_EVAL_PKGS_MIRRORS='if [ -n "${PACKAGE_MIRRORS_HOST:-}" ]; then \
    if [[ -n $(which apk) ]]; then  \
      # alpine
      sed -i "s/dl-cdn.alpinelinux.org/$PACKAGE_MIRRORS_HOST/g" /etc/apk/repositories && \
      apk update; \
    else \
      # debian
      sed -i "s/deb.debian.org/$PACKAGE_MIRRORS_HOST/g" /etc/apt/sources.list && \
      apt-get update; \
    fi \
  fi'

# For the alpine install glibc support , the install-glibc only support in jlesage/docker-baseimage
ARG RUN_EVAL_INSTALL_GLIBC_IN_ALPINE='if [[ -n $(which apk) ]]; then \
    if [ -n "${ALPINE_GLIBC_USE_GCOMPAT:-}" ]; then \
      add-pkg gcompat; \
    else \
      # the install_glibc use mirrors 
      if [ -n "${GITHUB_FILE_MIRRORS_HOST:-}" ]; then \
        cp /opt/base/bin/install-glibc /tmp/install-glibc && \
        sed -i "s#GLIBC_URL=https://github.com#GLIBC_URL=${GITHUB_FILE_MIRRORS_HOST}/https://github.com#g" /tmp/install-glibc && \
        # install-glibc self done clear /tmp
        /tmp/install-glibc ; \
      else \
        install-glibc; \
      fi \
    fi \
  fi'

# -----------------------------------------------------------------------------
# rebuild cinit for append option of no_pty, no_pty for services in 
# 'services.d/{services}/' , true value is service is not create 
# pseudo terminal, therefore cinit log based is disabled


# Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx


# Build UPX.
FROM --platform=$BUILDPLATFORM alpine:3.18 AS upx

ARG PACKAGE_MIRRORS_HOST
ARG ALPINE_GLIBC_USE_GCOMPAT
ARG GITHUB_FILE_MIRRORS_HOST

ARG RUN_EVAL_PKGS_MIRRORS

RUN eval $RUN_EVAL_PKGS_MIRRORS

RUN apk --no-cache add build-base curl make cmake git && \
    mkdir /tmp/upx && \
    if [ -n "${GITHUB_FILE_MIRRORS_HOST:-}" ]; then \
      curl -# -L "${GITHUB_FILE_MIRRORS_HOST}/https://github.com/upx/upx/releases/download/v4.1.0/upx-4.1.0-src.tar.xz" | tar xJ --strip 1 -C /tmp/upx ; \
    else \
      curl -# -L https://github.com/upx/upx/releases/download/v4.1.0/upx-4.1.0-src.tar.xz | tar xJ --strip 1 -C /tmp/upx ; \
    fi && \
    make -C /tmp/upx build/extra/gcc/release -j$(nproc) && \
    cp -v /tmp/upx/build/extra/gcc/release/upx /usr/bin/upx


# Build the init system and process supervisor.
FROM --platform=$BUILDPLATFORM alpine:3.18 AS cinit

ARG TARGETPLATFORM
COPY --from=xx / /
COPY src/cinit /tmp/cinit

ARG PACKAGE_MIRRORS_HOST=
ARG ALPINE_GLIBC_USE_GCOMPAT
ARG GITHUB_FILE_MIRRORS_HOST

ARG RUN_EVAL_PKGS_MIRRORS

RUN eval $RUN_EVAL_PKGS_MIRRORS
  
RUN apk --no-cache add make clang
RUN xx-apk --no-cache add gcc musl-dev
RUN CC=xx-clang \
    make -C /tmp/cinit
RUN xx-verify --static /tmp/cinit/cinit
COPY --from=upx /usr/bin/upx /usr/bin/upx
RUN upx /tmp/cinit/cinit


# =============================================================================

FROM browsh/browsh as browsh


FROM jlesage/firefox-esr

LABEL maintainer "https://github.com/sdaxia"

# # mirrors.ustc.edu.cn
ARG PACKAGE_MIRRORS_HOST=
ARG ALPINE_GLIBC_USE_GCOMPAT
ARG GITHUB_FILE_MIRRORS_HOST

ARG RUN_EVAL_PKGS_MIRRORS
ARG RUN_EVAL_INSTALL_GLIBC_IN_ALPINE

RUN eval $RUN_EVAL_PKGS_MIRRORS && eval $RUN_EVAL_INSTALL_GLIBC_IN_ALPINE

# copy file is needed by the browsh, copy the firefox extension and enable it is needed by the browsh 
COPY --link --from=browsh /app/bin/browsh /app/bin/browsh
COPY --link --from=browsh /app/.config/browsh/config.toml /app/data/browsh/.config/browsh/config.toml
COPY --link --from=browsh /app/.config/browsh/firefox_profile/extensions/ /app/data/browsh/.config/firefox/profile/extensions/ 
COPY --link --from=browsh /app/.config/browsh/firefox_profile/extensions.json /app/data/browsh/.config/firefox/profile/extensions.json

COPY /rootfs/ /

RUN \
  add-pkg jq && \ 
  # Let the browsh use exist the firefox
  sed -i 's/use-existing = false/use-existing = true/g' /app/data/browsh/.config/browsh/config.toml && \
  # Let the firefox use marionette mode, because the browsh need marionette
  sed -i '$aecho --marionette' /etc/services.d/app/params && \
  \
  # windows file power allow is rwxrwxrwx
  chmod 755 /app/bin/startbrowsh && \
  chmod 755 /etc/cont-init.d/57-browsh-install-addon.sh && \
  chmod 755 /etc/cont-init.d/57-browsh-set-config.sh && \
  chmod 644 /etc/services.d/default/browsh.dep && \
  chmod 644 /etc/services.d/browsh/app.dep && \
  chmod 755 /etc/services.d/browsh/disabled && \
  chmod 644 /etc/services.d/browsh/no_pty && \
  chmod 755 /etc/services.d/browsh/params && \
  chmod 755 /etc/services.d/browsh/respawn && \
  chmod 755 /etc/services.d/browsh/run && \
  chmod 755 /etc/services.d/browsh/shutdown_on_terminate && \
  chmod 644 /etc/services.d/browsh/sync

# Firefox behaves quite differently to normal on its first run, so by getting
# that over and done with here when there's no user to be dissapointed means
# that all future runs will be consistent.
RUN \
  TERM=xterm /bin/sh --return -s /bin/sh \
  -c "export XDG_CONFIG_HOME=/config/xdg/config && export XDG_DATA_HOME=/config/xdg/data && /app/bin/browsh" /dev/null \
  \
  sleep 10

# replace cinit of jlesage/docker-baseimage 
COPY --link --from=cinit /tmp/cinit/cinit /opt/base/sbin/

ENTRYPOINT ["/app/bin/startbrowsh"]
