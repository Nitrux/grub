#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2026 Nitrux Latinoamericana S.C. <hello@nxos.org>

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

if [[ "${EUID}" -eq 0 ]]; then
	APT=(apt-get)
else
	APT=(sudo apt-get)
fi

"${APT[@]}" update -q
"${APT[@]}" install -y --no-install-recommends \
	build-essential \
	devscripts \
	equivs \
	git \
	lintian

mk-build-deps \
	--install \
	--remove \
	--tool "apt-get --yes --no-install-recommends" \
	debian/control
