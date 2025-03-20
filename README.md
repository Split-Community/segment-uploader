# Split.io Segment Upload Utility

A command-line utility for uploading segment data to Split.io in manageable chunks. Split's [Segment Upload API](https://docs.split.io/reference/update-segment-keys-in-environment-via-csv) requires segments be broken upinto chunks of 10,000 and so this will take a file to be uploaded as an argument, break it up, and then proceed to upload it in chunks of 10,000 id values. 

Note that the segment must already exist in the environment. 

## Overview

This utility script makes it easy to upload large segment files to Split.io's API by:

1. Breaking large CSV files into smaller chunks
2. Uploading each chunk to the Split.io API
3. Cleaning up temporary files after successful uploads

## Requirements

- Bash shell
- curl
- split command (GNU split)
  - On macOS, this requires installing GNU coreutils: `brew install coreutils`

## Installation

1. Clone this repository or download the `upload-segment.sh` script
2. Make the script executable: `chmod +x upload-segment.sh`

## Usage

```
./upload-segment.sh -k APIKEY -e ENVIRONMENT_ID -s SEGMENT_NAME -f FILE_PATH
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `-k` | Split.io Admin API Key |
| `-e` | Split.io Environment ID |
| `-s` | Segment Name |
| `-f` | Path to CSV file containing segment data |
| `-h` | Show help message |

### Example

```bash
./upload-segment.sh -k YOUR_API_KEY -e YOUR_ENVIRONMENT_ID -s power_users -f /path/to/users.csv
```

## CSV File Format

The CSV file should contain the keys for your segment, with one key per line. For example:

```
user1@example.com
user2@example.com
user3@example.com
```

## How It Works

1. The script validates that all required parameters are provided
2. It checks if the specified file exists
3. The file is split into chunks of 10,000 lines each
4. Each chunk is uploaded to the Split.io API
5. Successfully uploaded chunks are removed automatically
6. Any failures are reported, and failed chunk files are preserved for debugging

## Troubleshooting

- If you encounter issues on macOS, ensure you have GNU coreutils installed: `brew install coreutils`
- Check that your API key has appropriate permissions
- Verify that the segment name is correct and exists in your Split.io environment
- If uploads fail, examine the preserved chunk files to identify any formatting issues

