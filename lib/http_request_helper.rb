require 'net/http'
require 'json'

class HttpRequestHelper 

  def self.get_youtube_video_info(url_input) 
    url_template = "https://www.googleapis.com/youtube/v3/videos?id=VIDEO_ID&key=API_KEY&part=snippet"
    api_key = ENV.fetch("YOUTUBE_API_KEY", nil)
    puts api_key
    video_id = url_input.split("v=").last
    url_api = url_template.gsub("VIDEO_ID", video_id).gsub("API_KEY", api_key)
    url = URI.parse(url_api)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.scheme == 'https'

    request = Net::HTTP::Get.new(url.request_uri)
    response = http.request(request)

    body = response.body
    JSON.parse(body)
  end

end
