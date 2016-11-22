#
# This is some logic that causes this to wait until 11am UTC (3am Pacific)
# for this to run. Eventually, this should be a cron once ECS supports cron.
#
NOW=`date -d "now" +%s`
TOMORROW_11AM=`date -d "tomorrow 11am" +%s`
SLEEP_TIME=$(($TOMORROW_11AM - $NOW))

echo "Sleeping $SLEEP_TIME seconds until 11am UTC tomorrow..."
sleep $SLEEP_TIME

#
# And this is where the real script begins!
#

echo "Running node import_month_to_date.js..."
node import_month_to_date.js --debug --no-vacuum
echo "Finished running import_month_to_date.js..."

echo "Running node import_finalized.js..."
node import_finalized.js --debug --no-vacuum
echo "Finished running import_finalized.js..."
