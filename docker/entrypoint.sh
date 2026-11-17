#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-or-later WITH AdditionRef-AIOMetadata-FSL-linking
# Copyright (C) 2021-2026 cedya77 and AIOMetadata contributors, see NOTICE
set -e

# Free single-container deployment: run the required Valkey 9 cache locally.
# Its data is intentionally ephemeral; do not treat this as durable production storage.
valkey-server --bind 127.0.0.1 --port 6379 --save "" --appendonly no --daemonize yes --logfile /tmp/valkey.log

export REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379}"
export DATABASE_URI="${DATABASE_URI:-sqlite:///tmp/aiometadata.db}"

exec node dist/server/server.js
