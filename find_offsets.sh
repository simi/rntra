#!/bin/bash

# Path to the CSV file containing video IDs (one per line)
csv_file="videos.csv"

# Path to the find-sections.py script
find_sections_script="find-sections-clever.py"

# Loop through each video ID in the CSV file
while IFS= read -r video_id; do
    # Construct the video path
    video_path="videos/${video_id}/video.mp4"

    if [[ ! -e "videos/${video_id}/offsets" ]]; then
        # Run the find-sections.py script
        python "$find_sections_script" "$video_path" 30 "f-artefakt.png" "f-datadisk.jpg" > "videos/${video_id}/offsets"
        printf "Processed video ID: $video_id\n"
    else
        printf "Offset file already exists for video ID: $video_id. Skipping.\n"
    fi

done < "$csv_file"

printf "All videos processed.\n"

