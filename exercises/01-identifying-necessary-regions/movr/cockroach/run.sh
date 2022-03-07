#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# start demo db with localities using  generic region names not gcp or aws specific 
cockroach demo --sql-port 26257 --no-example-database --nodes=9 --demo-locality=region=us-east1:region=us-east1:region=us-east2:region=us-west1:region=us-west1:region=us-west1:region=europe-west1:region=europe-west1:region=europe-west1 --empty
