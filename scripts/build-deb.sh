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
	grub-efi-amd64-unsigned
	grub2-common
)

cd "${REPO_ROOT}"

mkdir -p "${BUILD_DIR}"
rm -f -- "${BUILD_DIR}"/*.deb

debuild -b -uc -us

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

mv -- "${PACKAGES[@]}" "${BUILD_DIR}/"
