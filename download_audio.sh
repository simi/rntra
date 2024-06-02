#!/bin/bash
set -e

# Path to the videos.csv file containing video IDs (one per line)
csv_file="videos.csv"

# Create a directory to store downloaded audio files
mkdir -p videos

# Read video IDs from the CSV file and download audio for each video
while IFS= read -r video_id; do
    # Construct the YouTube video URL
    video_url="https://www.youtube.com/watch?v=${video_id}"

    # Create a folder with the video ID as the folder name
    folder_name="videos/${video_id}"
    mkdir -p "$folder_name"

    # Check if the audio file already exists, and skip downloading if it does
    if [[ ! -e "${folder_name}/audio.m4a" ]]; then
        # Download the audio to the folder as audio.m4a
        youtube-dl -x --audio-format m4a --output "${folder_name}/audio.%(ext)s" "$video_url"
        echo "Downloaded audio for video ID: $video_id"
    else
        echo "Audio file already exists for video ID: $video_id. Skipping."
    fi
done < "$csv_file"

echo "All videos processed."
