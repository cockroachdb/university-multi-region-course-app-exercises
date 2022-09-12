#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cockroach demo --sql-port 26257 --nodes=9 --no-example-database