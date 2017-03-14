#!/usr/bin/env bash

set -eo pipefail

#
# This is some logic that causes this to wait until 12am UTC (3am Pacific)
# for this to run. Eventually, this should be a cron once ECS supports cron.
#
sleep_until_3am_pacific() {
    local NOW=$(date -d "now" +%s)
    local TOMORROW_12PM=`date -d "tomorrow 12pm" +%s`
    local SLEEP_TIME=$(($TOMORROW_12PM - $NOW))

    echo "Sleeping $SLEEP_TIME seconds until 12pm UTC tomorrow..."
    sleep $SLEEP_TIME
}

import_month_to_date() {
    echo "Running node import_month_to_date.js..."
    node import_month_to_date.js --debug --no-vacuum
    echo "Finished running import_month_to_date.js..."
}

import_finalized() {
    echo "Running node import_finalized.js..."
    node import_finalized.js --debug --no-vacuum
    echo "Finished running import_finalized.js..."
}

main() {
    sleep_until_3am_pacific

    import_month_to_date
    import_finalized
}

main "$@"
