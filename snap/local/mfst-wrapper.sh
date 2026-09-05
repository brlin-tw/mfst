#!/usr/bin/env bash
# Launcher wrapper for Mikaey's Flash Stress Test Snap application
#
# Copyright 2026 林博仁(Buo-ren Lin) <buo.ren.lin@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
set -eu

if ! snapctl is-connected block-devices; then
    printf \
        'Error: The "block-devices" plug must be connected for mfst to access block devices.\n' \
        1>&2
    printf \
        'Please run: sudo snap connect %s:block-devices\n' \
        "${SNAP_NAME:-mfst}" \
        1>&2
    exit 1
fi

has_lockfile=false
for arg in "${@}"; do
    case "${arg}" in
        -f|--lockfile|-f=*|--lockfile=*)
            has_lockfile=true
            break
            ;;
    esac
done

if test "${has_lockfile}" = false; then
    if test -n "${SNAP_USER_COMMON:-}" && test -w "${SNAP_USER_COMMON:-}"; then
        lock_dir="${SNAP_USER_COMMON}"
    elif test -n "${SNAP_COMMON:-}" && test -w "${SNAP_COMMON:-}"; then
        lock_dir="${SNAP_COMMON}"
    elif test -n "${SNAP_USER_DATA:-}" && test -w "${SNAP_USER_DATA:-}"; then
        lock_dir="${SNAP_USER_DATA}"
    elif test -n "${SNAP_DATA:-}" && test -w "${SNAP_DATA:-}"; then
        lock_dir="${SNAP_DATA}"
    else
        lock_dir="/tmp"
    fi
    exec "${SNAP}/usr/bin/mfst" -f "${lock_dir}/mfst.lock" "${@}"
else
    exec "${SNAP}/usr/bin/mfst" "${@}"
fi
