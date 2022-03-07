#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# cockroach demo --sql-port 26257 --no-example-database
cockroach demo --global --sql-port 26257 --no-example-database --nodes 9

