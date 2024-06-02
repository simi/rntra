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

# Path to the CSV file containing video IDs (one per line)
csv_file = 'videos.csv'

# Path to the find-sections.py script
find_sections_script = 'find-sections-clever.py'

# Number of parallel jobs
parallel_jobs = 24 # Default to 10, but you can make it configurable

# Function to process a video given its ID
def process_video(video_id, find_sections_script)
  # Construct the video path
  video_path = "videos/#{video_id}/video.mp4"

  unless File.exist?("videos/#{video_id}/offsets")
    # Run the find-sections.py script
    system("python", find_sections_script, video_path, "30", "f-artefakt.png", "f-datadisk.jpg", out: "videos/#{video_id}/offsets", err: File::NULL)
  end
end

# Read video IDs from the CSV file
video_ids = CSV.read(csv_file).flatten

# Initialize progress bar
bar = ProgressBar.new(video_ids.size)

# Create a thread pool
pool = Concurrent::FixedThreadPool.new(parallel_jobs)

# Schedule video processing tasks
video_ids.each do |video_id|
  pool.post do
    process_video(video_id, find_sections_script)
    bar.increment!
  end
end

# Shut down the pool and wait for all tasks to complete
pool.shutdown
pool.wait_for_termination

puts 'All videos processed.'

