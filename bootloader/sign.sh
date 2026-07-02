#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <bootblock>" >&2
    exit 1
fi

file="$1"

# Get file size in bytes
n=$(wc -c < "$file")

if (( n > 510 )); then
    echo "boot block too large: $n bytes (max 510)" >&2
    exit 1
fi

echo "boot block is $n bytes (max 510)" >&2

# Pad to 510 bytes with zeros and append the boot signature.
(
    cat "$file"
    dd if=/dev/zero bs=1 count=$((510 - n)) status=none
    printf '\x55\xAA'
) > "${file}.tmp"

mv "${file}.tmp" "$file"
