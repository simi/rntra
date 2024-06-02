#!/bin/bash
set -e

# Path to the videos.csv file containing video IDs (one per line)
csv_file="videos.csv"

# Create a directory to store downloaded video files
mkdir -p videos

# Function to download a video given its ID
download_video() {
    video_id="$1"
    video_url="https://www.youtube.com/watch?v=${video_id}"
    folder_name="videos/${video_id}"
    mkdir -p "$folder_name"

    # Check if the video file already exists, and skip downloading if it does
    if [[ ! -e "${folder_name}/video.mp4" ]]; then
        # Download the video to the folder as video.mp4
        youtube-dl --format 160 --output "${folder_name}/video.%(ext)s" "$video_url"
        echo "Downloaded video for video ID: $video_id"
    else
        echo "Video file already exists for video ID: $video_id. Skipping."
    fi
}

export -f download_video

# Use xargs to download videos in parallel
cat "$csv_file" | xargs -I {} -P 10 bash -c 'download_video "$@"' _ {}

echo "All videos processed."

