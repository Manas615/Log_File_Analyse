#!/bin/bash

#####################################
# 1. Input Validation
#####################################

if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file_path>"
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' does not exist."
    exit 1
fi

#####################################
# 2. Variables and Setup
#####################################

REPORT_FILE="log_summary_report_$(date +%F).txt"
ERROR_KEYWORDS=("ERROR" "Failed")
CRITICAL_KEYWORD="CRITICAL"

#####################################
# 3. Analysis
#####################################

# Total lines processed
TOTAL_LINES=$(wc -l < "$LOG_FILE")

# Count errors (lines containing ERROR or Failed)
ERROR_COUNT=0
for keyword in "${ERROR_KEYWORDS[@]}"; do
    ERROR_COUNT=$((ERROR_COUNT + $(grep -c "$keyword" "$LOG_FILE")))
done

# Extract top 5 error messages (by message frequency)
ERROR_MESSAGES=$(grep -E "${ERROR_KEYWORDS[*]}" "$LOG_FILE" | \
    awk '{for(i=2;i<=NF;i++) printf $i " "; print ""}' | \
    sort | uniq -c | sort -nr | head -n 5)

# Identify critical events with line numbers
CRITICAL_EVENTS=$(grep -n "$CRITICAL_KEYWORD" "$LOG_FILE")

#####################################
# 4. Generate Summary Report
#####################################

echo "Log Analysis Report - $(date)" > "$REPORT_FILE"
echo "Log File: $LOG_FILE" >> "$REPORT_FILE"
echo "Total Lines Processed: $TOTAL_LINES" >> "$REPORT_FILE"
echo "Total Error Count: $ERROR_COUNT" >> "$REPORT_FILE"
echo -e "\nTop 5 Error Messages:" >> "$REPORT_FILE"
if [ -z "$ERROR_MESSAGES" ]; then
    echo "None" >> "$REPORT_FILE"
else
    echo "$ERROR_MESSAGES" >> "$REPORT_FILE"
fi
echo -e "\nCritical Events (Line Numbers):" >> "$REPORT_FILE"
if [ -z "$CRITICAL_EVENTS" ]; then
    echo "None" >> "$REPORT_FILE"
else
    echo "$CRITICAL_EVENTS" >> "$REPORT_FILE"
fi

#####################################
# 5. Archive Processed Log File
#####################################

ARCHIVE_DIR="processed_logs"
mkdir -p "$ARCHIVE_DIR"
mv "$LOG_FILE" "$ARCHIVE_DIR/"
echo "Log file moved to $ARCHIVE_DIR/"

#####################################
# 6. Completion Message
#####################################

echo "Log analysis complete. Report saved to $REPORT_FILE."
exit 0
