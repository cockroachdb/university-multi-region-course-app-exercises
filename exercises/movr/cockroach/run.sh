#!/bin/bash
set -euo pipefail
IFS=$'\n\t'



# start demo db with localities using  generic region names not gcp or aws specific 
cockroach demo --sql-port 26257 --no-example-database --nodes=9 --demo-locality=region=us-east,zone=a:region=us-east,zone=b:region=us-east,zone=c:region=us-west,zone=b:region=us-west,zone=c:region=us-west,zone=d:region=us-central,zone=a:region=sa-east,zone=b:region=eu-central,zone=c --empty