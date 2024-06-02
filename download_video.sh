#!/bin/bash
set -e

# Path to the videos.csv file containing video IDs (one per line)
csv_file="videos.csv"

# Create a directory to store downloaded video files
mkdir -p videos

# Read video IDs from the CSV file and download video for each video
while IFS= read -r video_id; do
    # Construct the YouTube video URL
    video_url="https://www.youtube.com/watch?v=${video_id}"

    # Create a folder with the video ID as the folder name
    folder_name="videos/${video_id}"
    mkdir -p "$folder_name"

    # Check if the video file already exists, and skip downloading if it does
    if [[ ! -e "${folder_name}/video.mp4" ]]; then
        # Download the video to the folder as video.m4a
        youtube-dl --format 160 --output "${folder_name}/video.%(ext)s" "$video_url"
        echo "Downloaded video for video ID: $video_id"
    else
        echo "Video file already exists for video ID: $video_id. Skipping."
    fi
done < "$csv_file"

echo "All videos processed."
