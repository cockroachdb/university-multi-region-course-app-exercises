#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

pkill -term -f 'cockroach demo'

cockroach demo --sql-port 26257 --nodes=9 --no-example-database