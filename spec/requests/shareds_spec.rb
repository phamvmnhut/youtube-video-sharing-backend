RSpec.describe 'Shareds API', type: :request do
  describe 'GET /shareds' do
    let!(:shareds) { create_list(:shared, 15) }

    context 'when page and per_page parameters are provided' do
      it 'returns the specified page of shareds' do
        get '/shareds', params: { page: 2, per_page: 5 }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(5)
      end

      it 'returns the correct pagination information' do
        get '/shareds', params: { page: 2, per_page: 5 }

        pagination_info = JSON.parse(response.body)['pagination']

        expect(pagination_info['total_pages']).to eq(3)
        expect(pagination_info['current_page']).to eq(2)
        expect(pagination_info['total_records']).to eq(15)
        expect(pagination_info['per_page']).to eq(5)
      end
    end

    context 'when page and per_page parameters are not provided' do
      it 'returns the first page with default per_page value' do
        get '/shareds'

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(10)
      end

      it 'returns the correct default pagination information' do
        get '/shareds'

        pagination_info = JSON.parse(response.body)['pagination']

        expect(pagination_info['total_pages']).to eq(2)
        expect(pagination_info['current_page']).to eq(1)
        expect(pagination_info['total_records']).to eq(15)
        expect(pagination_info['per_page']).to eq(10)
      end
    end
  end

  describe 'POST /shareds' do
    let(:user) { create(:user) }

    before do
      ENV['YOUTUBE_API_KEY'] = 'my-youtube-api-key'
    end

    context 'with a valid URL' do
      before do
        stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=12345&key=my-youtube-api-key&part=snippet")
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })
        .to_return(status: 200, body: { items: [{snippet: {title: "Video title", description: "Video desciption"}}] }.to_json)
      end

      let(:valid_params) { { shareds: { url: 'https://www.youtube.com/watch?v=12345' } } }

      it 'creates a new shared' do
        expect {
          post '/shareds', params: valid_params, headers: authenticated_header(user)
        }.to change(Shared, :count).by(1)

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["data"]["url"]).to eq("https://www.youtube.com/watch?v=12345")
      end
    end

    context 'with an invalid URL' do
      before do
        stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=invalid_url&key=my-youtube-api-key&part=snippet")
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })
        .to_return(status: 200, body: { items: [] }.to_json)
      end

      let(:invalid_params) { { shareds: { url: 'https://www.youtube.com/watch?v=invalid_url' } } }

      it 'returns an error' do
        post '/shareds', params: invalid_params, headers: authenticated_header(user)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('url video is invalid')
      end
    end
  end
end
