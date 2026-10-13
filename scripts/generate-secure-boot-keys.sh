#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2026 Nitrux Latinoamericana S.C. <hello@nxos.org>

set -euo pipefail

if (($# != 1)); then
	echo "Usage: $0 OUTPUT-DIRECTORY" >&2
	exit 2
fi

OUTPUT_DIR="$1"
KEY_NAME="${SB_KEY_NAME:-grub}"
CERT_SUBJECT="${SB_CERT_SUBJECT:-/CN=Nitrux GRUB Secure Boot Signing Key/}"
CERT_DAYS="${SB_CERT_DAYS:-3650}"
KEY_FILE="${OUTPUT_DIR}/${KEY_NAME}.key"
CERT_FILE="${OUTPUT_DIR}/${KEY_NAME}.crt"
DER_FILE="${OUTPUT_DIR}/${KEY_NAME}.cer"

if [[ -e "${KEY_FILE}" || -e "${CERT_FILE}" || -e "${DER_FILE}" ]]; then
	echo "Refusing to overwrite existing Secure Boot key files in: ${OUTPUT_DIR}" >&2
	exit 1
fi

umask 077
mkdir -p -- "${OUTPUT_DIR}"

openssl req \
	-new \
	-newkey rsa:4096 \
	-nodes \
	-sha256 \
	-x509 \
	-days "${CERT_DAYS}" \
	-subj "${CERT_SUBJECT}" \
	-keyout "${KEY_FILE}" \
	-out "${CERT_FILE}"
openssl x509 -in "${CERT_FILE}" -outform DER -out "${DER_FILE}"

echo "Created: ${KEY_FILE}"
echo "Created: ${CERT_FILE}"
echo "Created: ${DER_FILE}"
