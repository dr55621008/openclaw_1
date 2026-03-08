#!/bin/bash
# HKG-CDG Flight Price Monitor - Background Runner
# Runs every 6 hours for 5 days (20 iterations)

SCRIPT_DIR="/data/.openclaw/workspace/flight-prices/scripts"
LOG_FILE="/tmp/flight-monitor.log"
INTERVAL=21600  # 6 hours in seconds
MAX_RUNS=20     # 5 days * 4 times per day

echo "Starting HKG-CDG Flight Price Monitor"
echo "Interval: 6 hours"
echo "Max runs: $MAX_RUNS"
echo "Log file: $LOG_FILE"
echo "Start time: $(date)"

for i in $(seq 1 $MAX_RUNS); do
    echo "=== Run #$i at $(date) ===" >> "$LOG_FILE"
    
    # Run the update script
    if bash "$SCRIPT_DIR/update-flight-report.sh" >> "$LOG_FILE" 2>&1; then
        echo "✓ Update successful at $(date)" >> "$LOG_FILE"
    else
        echo "✗ Update failed at $(date)" >> "$LOG_FILE"
    fi
    
    if [ $i -lt $MAX_RUNS ]; then
        echo "Sleeping for 6 hours... (next run: $(date -d "+6 hours"))" >> "$LOG_FILE"
        sleep $INTERVAL
    fi
done

echo "=== Monitoring complete at $(date) ===" >> "$LOG_FILE"
echo "Flight price monitoring completed after $MAX_RUNS runs"
