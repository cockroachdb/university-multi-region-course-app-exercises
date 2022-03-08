#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# start demo db with localities using  generic region names not gcp or aws specific 
cockroach demo --sql-port 26257 --no-example-database --nodes=9 --demo-locality=region=us-east1,zone=a:region=us-east1,zone=b:region=us-east2,zone=c:region=us-west1,zone=b:region=us-west1,zone=c:region=us-west1,zone=d:region=europe-west1,zone=a:region=europe-west1,zone=b:region=europe-west1,zone=c --empty
