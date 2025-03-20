#!/bin/bash

show_help() {
    echo "Usage: $0 -k APIKEY -e ENVIRONMENT_ID -s SEGMENT_NAME -f FILE_PATH"
    echo
    echo "Options:"
    echo "  -k  APIKEY          Admin API Key"
    echo "  -e  ENVIRONMENT_ID  Environment ID"
    echo "  -s  SEGMENT_NAME    Segment Name"
    echo "  -f  FILE_PATH       Path to file"
    echo "  -h                  Show this help message"
    exit 0
}

# Initialize variables
API_KEY=""
ENVID=""
SEGMENT_NAME=""
FILE_PATH=""

# Parse options with getopts
while getopts "k:e:s:f:h" opt; do
  case $opt in
    k) API_KEY="$OPTARG" ;;
    e) ENVID="$OPTARG" ;;
    s) SEGMENT_NAME="$OPTARG" ;;
    f) FILE_PATH="$OPTARG" ;;
    h) show_help ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

# Check required arguments
MISSING=0
[ -z "$API_KEY" ] && { echo "Error: Missing -k APIKEY"; MISSING=1; }
[ -z "$ENVID" ] && { echo "Error: Missing -e ENVIRONMENT_ID"; MISSING=1; }
[ -z "$SEGMENT_NAME" ] && { echo "Error: Missing -s SEGMENT_NAME"; MISSING=1; }
[ -z "$FILE_PATH" ] && { echo "Error: Missing -f FILE_PATH"; MISSING=1; }
[ $MISSING -ne 0 ] && exit 1

# Check if file exists
[ ! -f "$FILE_PATH" ] && { echo "Error: File $FILE_PATH not found"; exit 1; }

CHUNK_PREFIX="chunk_"
API_ENDPOINT="https://api.split.io/internal/api/v2/segments/$ENVID/$SEGMENT_NAME/upload"

# Detect operating system and use appropriate split command
SPLIT_CMD="split"
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS uses gsplit (GNU split) which can be installed with brew
    if command -v gsplit >/dev/null 2>&1; then
        SPLIT_CMD="gsplit"
    else
        echo "Warning: On macOS but gsplit not found. Trying to use built-in split command."
        echo "If this fails, install gsplit with: brew install coreutils"
    fi
fi

# Split the input file
$SPLIT_CMD -l 10000 --additional-suffix=.csv "$FILE_PATH" "$CHUNK_PREFIX"

# Process chunks
for chunk in "${CHUNK_PREFIX}"*.csv; do
    echo "Posting $chunk to API..."
    if curl --fail -X PUT \
            -H "Authorization: Bearer $API_KEY" \
            -F "file=@$chunk" \
            "$API_ENDPOINT"; then
        echo "Successfully uploaded $chunk, removing file..."
        rm "$chunk"
    else
        echo "Error: Failed to upload $chunk - file preserved"
    fi
    sleep 1
done

echo "Processing complete."
