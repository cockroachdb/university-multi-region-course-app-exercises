#!/bin/bash
set -euo pipefail
IFS=$'\n\t'



cockroach demo --sql-port 26257 --no-example-database --nodes=9 --demo-locality=region=us-east,zone=a:region=us-east,zone=b:region=us-east,zone=c:region=us-west,zone=b:region=us-west,zone=c:region=us-west,zone=d:region=us-central,zone=a:region=us-central,zone=d:region=us-central,zone=f 