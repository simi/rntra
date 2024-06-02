require 'csv'
require 'fileutils'

# Path to the CSV file containing video IDs (one per line)
csv_file = 'videos.csv'

# Output CSV file to store offsets data
output_csv = 'offsets.csv'

# Function to create a YouTube link with a timestamp
def create_youtube_link(video_id, offset)
  "https://www.youtube.com/watch?v=#{video_id}&t=#{offset}s" unless offset.nil? || offset.empty?
end

# Create the CSV file with headers
CSV.open(output_csv, 'w') do |csv|
  csv << ['video_id', 'artefakt_offset', 'datadisk_offset', 'video_link', 'artefakt_link', 'datadisk_link']

  # Loop through each video ID in the CSV file
  CSV.foreach(csv_file) do |row|
    video_id = row[0]

    # Construct the path to the offset file
    offset_file = "videos/#{video_id}/offsets"

    # Initialize variables to store offsets
    first_offset = ''
    second_offset = ''

    # Check if the offset file exists
    if File.exist?(offset_file)
      # Read the first and second offsets from the file, skipping empty lines
      offsets = File.readlines(offset_file).map(&:strip).reject(&:empty?)
      first_offset = offsets[0].strip unless offsets[0].nil?
      second_offset = offsets[1].strip unless offsets[1].nil?
    end

    # Create YouTube links
    video_link = "https://www.youtube.com/watch?v=#{video_id}"
    artefakt_link = create_youtube_link(video_id, first_offset)
    datadisk_link = create_youtube_link(video_id, second_offset)

    # Append the data to the CSV file
    csv << [video_id, first_offset, second_offset, video_link, artefakt_link, datadisk_link]
  end
end

puts "Offsets data collected and saved to #{output_csv}"
