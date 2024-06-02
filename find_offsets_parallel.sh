#!/bin/bash

# Path to the CSV file containing video IDs (one per line)
csv_file="videos.csv"

# Path to the find-sections.py script
find_sections_script="find-sections-clever.py"

# Number of parallel jobs
parallel_jobs=10 # Default to 10, but you can make it configurable by passing an argument or environment variable

process_video() {
    video_id="$1"
    # Construct the video path
    video_path="videos/${video_id}/video.mp4"

    if [[ ! -e "videos/${video_id}/offsets" ]]; then
        # Run the find-sections.py script
        python "$find_sections_script" "$video_path" 30 "f-artefakt.png" "f-datadisk.jpg" > "videos/${video_id}/offsets"
        printf "Processed video ID: $video_id\n"
    else
        printf "Offset file already exists for video ID: $video_id. Skipping.\n"
    fi
}

export -f process_video
export find_sections_script

# Use GNU Parallel to process videos in parallel
parallel -j $parallel_jobs process_video :::: "$csv_file"

printf "All videos processed.\n"
