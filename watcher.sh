#!/usr/bin/env bash

TARGET_DIR="/home/wingej0"

# -m: monitor indefinitely
# -e create: listen for file creation events
# --format '%w%f': output the full path to the created file
inotifywait -m -r -e create --format '%w%f' "$TARGET_DIR" | while read NEW_FILE
do
    echo "New file created: $NEW_FILE"
    # Add your desired actions here, e.g.,
    # cp "$NEW_FILE" /another/location/
    # process_file "$NEW_FILE"
done
