echo "Running node import_month_to_date.js..."
node import_month_to_date.js --debug --no-vacuum
echo "Finished running import_month_to_date.js..."

echo "Running node import_finalized.js..."
node import_finalized.js --debug --no-vacuum
echo "Finished running import_finalized.js..."

sleep 82800
