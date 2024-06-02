#!/bin/bash

# Path to the CSV file containing video IDs (one per line)
csv_file="videos.csv"

# Output CSV file to store offsets data
output_csv="offsets.csv"

# Create the CSV file with headers
echo "video_id,artefakt_offset,datadisk_offset" > "$output_csv"

# Loop through each video ID in the CSV file
while IFS= read -r video_id; do
    # Construct the path to the offset file
    offset_file="videos/${video_id}/offsets"

    # Initialize variables to store offsets
    first_offset=""
    second_offset=""

    # Check if the offset file exists
    if [ -f "$offset_file" ]; then
        # Read the first and second offsets from the file, skipping empty lines
        first_offset=$(awk 'NF{print; exit}' "$offset_file")
        second_offset=$(awk 'NR==2' "$offset_file")
    fi

    # Append the data to the CSV file
    echo "$video_id,$first_offset,$second_offset" >> "$output_csv"

done < "$csv_file"

echo "Offsets data collected and saved to $output_csv"
