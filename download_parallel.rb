require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'csv'
  gem 'concurrent-ruby'
  gem 'progress_bar'
end

require 'csv'
require 'concurrent'
require 'fileutils'
require 'progress_bar'

# Path to the videos.csv file containing video IDs (one per line)
csv_file = 'videos.csv'

# Create a directory to store downloaded video files
FileUtils.mkdir_p('videos')

# Function to download a video given its ID
def download_video(video_id)
  video_url = "https://www.youtube.com/watch?v=#{video_id}"
  folder_name = "videos/#{video_id}"
  FileUtils.mkdir_p(folder_name)

  # Check if the video file already exists, and skip downloading if it does
  unless File.exist?(File.join(folder_name, 'video.mp4'))
    system("youtube-dl", "--format", "160", "--output", File.join(folder_name, "video.%(ext)s"), video_url, out: File::NULL, err: File::NULL)
  end

  # Check if the audio file already exists, and skip downloading if it does
  unless File.exist?(File.join(folder_name, 'audio.m4a'))
    system("youtube-dl", "-x", "--audio-format", "m4a", "--output", File.join(folder_name, "audio.%(ext)s"), video_url, out: File::NULL, err: File::NULL)
  end
end

# Read video IDs from the CSV file
video_ids = CSV.read(csv_file).flatten

# Initialize progress bar
bar = ProgressBar.new(video_ids.size)

# Create a thread pool
pool = Concurrent::FixedThreadPool.new(10)

# Schedule video download tasks
video_ids.each do |video_id|
  pool.post do
    download_video(video_id)
    bar.increment!
  end
end

# Shut down the pool and wait for all tasks to complete
pool.shutdown
pool.wait_for_termination

puts 'All videos processed.'
