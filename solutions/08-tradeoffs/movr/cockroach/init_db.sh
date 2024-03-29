#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

function help {
    echo "This command will run a series of SQL commands to initialize the MovR databases."
    echo ""
    echo "USAGE: init_db.sh <url>"
    echo ""
    echo "<url>          The URL to connect to the database on (sql/unix)."
}

URL=${1:-}

if [ -z $URL ]
then
    help
    exit 2
fi

echo "----------------------------------------------------------------------"
echo "CONNECTING TO COCKROACH_DB"
echo "$URL"
echo "----------------------------------------------------------------------"

echo "----------------------------------------------------------------------"
echo "UPDATING CLUSTER TO SUPPORT PLACEMENT RESTRICTED "
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --execute 'SET CLUSTER SETTING sql.defaults.multiregion_placement_policy.enabled = on;'

echo "----------------------------------------------------------------------"
echo "ENABLE SUPER REGIONS"
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --execute 'SET CLUSTER SETTING  sql.defaults.super_regions.enabled = true;'

echo "----------------------------------------------------------------------"
echo "INITIALIZING RIDES DATABASE: ../rides/data/rides_database.sql"
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --file '../rides/data/rides_database.sql'

echo "----------------------------------------------------------------------"
echo "INITIALIZING VEHICLES DATABASE: ../vehicles/data/vehicles_database.sql"
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --file '../vehicles/data/vehicles_database.sql'

echo "----------------------------------------------------------------------"
echo "INITIALIZING USERS DATABASE: ../users/data/users_database.sql"
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --file '../users/data/users_database.sql'

echo "----------------------------------------------------------------------"
echo "INITIALIZING PRICING DATABASE: ../pricing/data/pricing_database.sql"
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --file '../pricing/data/pricing_database.sql'


echo "----------------------------------------------------------------------"
echo "INITIALIZING PRICING DATABASE: ../pricing/data/pricing_database.sql"
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --file '../pricing/data/pricing_database.sql'


echo "----------------------------------------------------------------------"
echo "UPDATING DEMO PASSWORD (movr) "
echo "----------------------------------------------------------------------"
cockroach sql --url $URL --execute $'ALTER USER demo with password \'movr\';'


