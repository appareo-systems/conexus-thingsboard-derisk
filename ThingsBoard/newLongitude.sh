#!/bin/bash

# Define the constant LONGITUDE
LONGITUDE=2.260505


# Define the temp file to store the increment
TEMP_FILE="./longitude_incr.txt"

# Check if the temp file exists, if not, initialize it with 0
if [ ! -f "$TEMP_FILE" ]; then
  echo "0" > "$TEMP_FILE"
fi

# Read the current increment from the temp file
LONGITUDE_INCR=$(cat "$TEMP_FILE")

# Increment LONGITUDE_INCR by 0.00001
LONGITUDE_INCR=$(echo "$LONGITUDE_INCR + 0.001" | bc)

# Write the updated increment back to the temp file
echo "$LONGITUDE_INCR" > "$TEMP_FILE"

# Check if LONGITUDE_INCR is set, if not, initialize it to 0
if [ -z "$LONGITUDE_INCR" ]; then
  LONGITUDE_INCR=0
fi

# Calculate the new longitude value
export NEW_LONGITUDE=$(echo "$LONGITUDE + $LONGITUDE_INCR" | bc)

# Echo the new longitude value
echo "New Longitude: $NEW_LONGITUDE"


