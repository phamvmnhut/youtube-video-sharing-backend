require 'net/http'
require 'json'
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe HttpRequestHelper do
  describe '#get_youtube_video_info' do
    let!(:youtube_api_key) { "your_api_key" }
    let!(:video_id) { 'ABCxyz' }
    let!(:url_input) { "https://www.youtube.com/watch?v=#{video_id}" }

    before do
      Rails.application.credentials.youtube_api_key = youtube_api_key
    end

    it 'returns video information from YouTube API' do
      stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=ABCxyz&key=AIzaSyCaT6wF_cz9Qy9n0un3KpkwT9q5nhwRFKQ&part=snippet")
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })
        .to_return(status: 200, body: { title: 'Video Title' }.to_json)

      result = HttpRequestHelper.get_youtube_video_info(url_input)

      expect(result["title"]).to eq('Video Title')
    end
  end
end
