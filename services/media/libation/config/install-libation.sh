#!/usr/bin/with-contenv bash
# shellcheck shell=bash
# Runs as root from /custom-cont-init.d after the base image init, before the desktop starts.
# https://docs.linuxserver.io/general/container-customization/#custom-scripts
set -euo pipefail

# renovate: datasource=github-releases depName=rmcrackan/Libation
LIBATION_VERSION=v14.2.5

LIBATION_FILES="${LIBATION_FILES_DIR:-${HOME}/Libation}"
# populated by migrate-settings.sh, moved into place before libation starts
IMPORT_DIR="${HOME}/libation-import"

# the container filesystem survives container restarts, but not a new pod
if [[ "$(cat /usr/lib/libation/.version 2>/dev/null)" != "${LIBATION_VERSION}" ]]; then
  echo "**** installing libation ${LIBATION_VERSION} ****"
  # .NET requires icu, match the package by pattern since its name includes the version
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    "$(apt-cache search --names-only '^libicu[0-9]+$' | cut -d' ' -f1)"
  version="${LIBATION_VERSION#v}"
  deb="$(mktemp --suffix=.deb)"
  curl -fsSL -o "${deb}" \
    "https://github.com/rmcrackan/Libation/releases/download/${LIBATION_VERSION}/Libation.${version}-linux-chardonnay-$(dpkg --print-architecture).deb"
  # extract instead of installing, postinst runs sysctl which fails in an unprivileged container
  dpkg-deb -x "${deb}" /
  rm "${deb}"
  ln -sf /usr/lib/libation/Libation /usr/bin/libation
  ln -sf /usr/lib/libation/LibationCli /usr/bin/libationcli
  echo "${LIBATION_VERSION}" > /usr/lib/libation/.version
fi

if [[ -d "${IMPORT_DIR}" ]]; then
  echo "**** importing libation settings from ${IMPORT_DIR} ****"
  if [[ -e "${LIBATION_FILES}" ]]; then
    mv "${LIBATION_FILES}" "${LIBATION_FILES}.$(date +%Y%m%d-%H%M%S)"
  fi
  mv "${IMPORT_DIR}" "${LIBATION_FILES}"
  chown -R abc:abc "${LIBATION_FILES}"
fi

# replace the default terminal with libation, RESTART_APP relaunches it if closed
autostart="${HOME}/.config/openbox/autostart"
echo "libation" > "${autostart}"
# match the base image's lockdown when RESTART_APP is set
chown root:abc "${autostart}"
chmod 550 "${autostart}"
