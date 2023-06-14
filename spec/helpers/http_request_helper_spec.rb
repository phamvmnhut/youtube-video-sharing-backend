require 'net/http'
require 'json'
require 'rails_helper'
require 'webmock/rspec'

RSpec.describe HttpRequestHelper do
  describe '#get_youtube_video_info' do
    let!(:video_id) { 'ABCxyz' }
    let!(:url_input) { "https://www.youtube.com/watch?v=#{video_id}" }

    before do
      ENV['YOUTUBE_API_KEY'] = 'my-youtube-api-key'
      stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=ABCxyz&key=my-youtube-api-key&part=snippet")
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })
        .to_return(status: 200, body: { title: 'Video Title' }.to_json)
    end

    it 'returns video information from YouTube API' do
      result = HttpRequestHelper.get_youtube_video_info(url_input)
      expect(result["title"]).to eq('Video Title')
    end
  end
end
