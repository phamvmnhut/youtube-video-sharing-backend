require 'rails_helper'

RSpec.describe SharedsController, type: :controller do

  # before(:each) do
  #   User.destroy_all
  # end

  describe "GET #index" do
    let!(:shareds) { create_list(:shared, 15) }

    context 'when page and per_page parameters are provided' do
      it 'returns the specified page of shareds' do
        get :index, params: { page: 2, per_page: 5 }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(5)
      end

      it 'returns the correct pagination information' do
        get :index, params: { page: 2, per_page: 5 }

        pagination_info = JSON.parse(response.body)['pagination']

        expect(pagination_info['total_pages']).to eq(3)
        expect(pagination_info['current_page']).to eq(2)
        expect(pagination_info['total_records']).to eq(15)
        expect(pagination_info['per_page']).to eq(5)
      end
    end

    context 'when page and per_page parameters are not provided' do
      it 'returns the first page with default per_page value' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].size).to eq(10)
      end

      it 'returns the correct default pagination information' do
        get :index

        pagination_info = JSON.parse(response.body)['pagination']

        expect(pagination_info['total_pages']).to eq(2)
        expect(pagination_info['current_page']).to eq(1)
        expect(pagination_info['total_records']).to eq(15)
        expect(pagination_info['per_page']).to eq(10)
      end
    end
  end

  describe "POST #create" do
    let!(:user) { create(:user) }
    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      ENV['YOUTUBE_API_KEY'] = 'my-youtube-api-key'
    end

    context "when valid parameters are provided" do
      let!(:valid_params) { { shareds: { url: "https://www.youtube.com/watch?v=12345" } } }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?id=12345&key=my-youtube-api-key&part=snippet")
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        })
        .to_return(status: 200, body: { items: [{snippet: {title: "Video title", description: "Video desciption"}}] }.to_json)
      end

      it "creates a new shared" do
        expect {
          post :create, params: valid_params
        }.to change(Shared, :count).by(1)
      end

      it "returns a success response" do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it "returns the created shared" do
        post :create, params: valid_params
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["data"]["url"]).to eq("https://www.youtube.com/watch?v=12345")
      end
    end

    context "when invalid parameters are provided" do
      let!(:invalid_params) { { shareds: { url: "" } } }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "does not create a new shared" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        expect {
          post :create, params: invalid_params
        }.not_to change(Shared, :count)
      end

      it "returns a not found response" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        post :create, params: invalid_params
        expect(response).to have_http_status(:bad_request)
      end

      it "returns the error message" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        post :create, params: invalid_params
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq("url video is invalid")
      end
    end
  end

  describe "GET #show" do
    let!(:user) { create(:user) }
    let!(:shared) { create(:shared, user: user) }
    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when shared is found" do
      it "returns a success response" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        get :show, params: { id: shared.id }
        expect(response).to have_http_status(:ok)
      end

      it "returns the requested shared" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        get :show, params: { id: shared.id }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["data"]["id"]).to eq(shared.id)
      end
    end

    context "when shared is not found" do
      it "returns a not found response" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        get :show, params: { id: 999 }
        expect(response).to have_http_status(:not_found)
      end
      it "returns the error message" do
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        get :show, params: { id: 999 }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["error"]).to eq("Shared not found")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:user) }
    let!(:shared) { create(:shared, user: user) }
    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end
    
    it "destroys the shared" do
      expect {
        request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
        delete :destroy, params: { id: shared.id }
      }.to change(Shared, :count).by(-1)
    end
    
    it "returns a no content response" do
      request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
      delete :destroy, params: { id: shared.id }
      expect(response).to have_http_status(:no_content)
    end
  end

end
