#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2026 Nitrux Latinoamericana S.C. <hello@nxos.org>

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${REPO_ROOT}/build}"

PACKAGE_NAMES=(
	grub-efi-amd64
	grub-efi-amd64-bin
	grub-efi-amd64-signed
	grub2-common
)

PACKAGE_OPTIONS=()
for package_name in "${PACKAGE_NAMES[@]}"; do
	PACKAGE_OPTIONS+=("-p${package_name}")
done

cd "${REPO_ROOT}"

: "${SB_KEY:?Set SB_KEY to the Secure Boot private key before building.}"
: "${SB_CERT:?Set SB_CERT to the Secure Boot certificate before building.}"

mkdir -p "${BUILD_DIR}"
rm -f -- "${BUILD_DIR}"/*.deb

DEB_BUILD_OPTIONS="${DEB_BUILD_OPTIONS:+${DEB_BUILD_OPTIONS} }nocheck" \
	DH_OPTIONS="${PACKAGE_OPTIONS[*]}" \
debuild --preserve-envvar=DH_OPTIONS --preserve-envvar=SB_KEY --preserve-envvar=SB_CERT -b -uc -us

shopt -s nullglob
PACKAGES=()
for package_name in "${PACKAGE_NAMES[@]}"; do
	matches=(../"${package_name}"_*.deb)
	if (("${#matches[@]}" != 1)); then
		echo "Expected exactly one package for ${package_name}, found ${#matches[@]}." >&2
		exit 1
	fi
	PACKAGES+=("${matches[0]}")
done
shopt -u nullglob

signed_package=""
for package in "${PACKAGES[@]}"; do
	if [[ "$(basename "${package}")" == grub-efi-amd64-signed_*.deb ]]; then
		signed_package="${package}"
	fi
done

if [ -z "${signed_package}" ]; then
	echo "Error: grub-efi-amd64-signed does not contain gcdx64.efi.signed." >&2
	exit 1
fi

signed_package_contents="$(dpkg-deb --contents "${signed_package}")"
if ! grep -Fq 'usr/lib/grub/x86_64-efi-signed/gcdx64.efi.signed' <<< "${signed_package_contents}"; then
	echo "Error: grub-efi-amd64-signed does not contain gcdx64.efi.signed." >&2
	exit 1
fi

mv -- "${PACKAGES[@]}" "${BUILD_DIR}/"
