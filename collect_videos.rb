require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'google-api-client'
  gem 'csv'
  gem 'net-http'
end

require 'google/apis/youtube_v3'
require 'csv'

# Your YouTube API key from the environment variable
api_key = ENV['YOUTUBE_API_KEY'] || "AIzaSyB8dZob6X5f75DhlH09Ra7noAEZXb_7g-w"

# YouTube playlist ID to scrape
playlist_id = 'PLDW0o0KhZdiAz-FwurTta-LxIMRTPUQN_'

# Output CSV file
output_csv = 'youtube_videos.csv'

# Initialize YouTube API client
youtube = Google::Apis::YoutubeV3::YouTubeService.new
youtube.key = api_key

# Function to fetch playlist items
def fetch_playlist_items(youtube, playlist_id, page_token = nil)
  youtube.list_playlist_items(
    'snippet',
    playlist_id: playlist_id,
    max_results: 50,
    page_token: page_token
  )
end

# Hash to store the earliest publication date for each video
video_data = {}

# Pagination to handle multiple pages of results
page_token = nil
loop do
  response = fetch_playlist_items(youtube, playlist_id, page_token)
  response.items.each do |item|
    video_id = item.snippet.resource_id.video_id
    title = item.snippet.title
    published_at = item.snippet.published_at

    if video_data[video_id]
      existing_published_at = video_data[video_id][:published_at]
      if DateTime.parse(published_at) < DateTime.parse(existing_published_at)
        video_data[video_id] = { title: title, published_at: published_at }
      end
    else
      video_data[video_id] = { title: title, published_at: published_at }
    end
  end
  page_token = response.next_page_token
  break unless page_token
end

# Write to CSV file
CSV.open(output_csv, 'w') do |csv|
  csv << ['video_id', 'title', 'published_at']
  video_data.each do |video_id, data|
    csv << [video_id, data[:title], data[:published_at]]
  end
end

puts "Videos data collected and saved to #{output_csv}"
