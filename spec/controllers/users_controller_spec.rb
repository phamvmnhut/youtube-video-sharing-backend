require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #show" do
    context "when user exists" do
      let!(:user) { User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password") }

      it "renders JSON response with user data and shareds" do
        get :show, params: { id: user.id }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response["data"]["name"]).to eq(user.name)
        expect(json_response["data"]["email"]).to eq(user.email)
        expect(json_response["data"]["shareds"]).to eq(user.shareds.as_json)
      end
    end

    context "when user does not exist" do
      it "renders JSON response with error message" do
        get :show, params: { id: 999 }

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("User not found")
      end
    end
  end
end