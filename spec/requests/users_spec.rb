require 'rails_helper'

RSpec.describe "User API", type: :request do
  describe "POST /registrations" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          users: {
            name: "test_name",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "creates a new user" do
        expect {
          post "/registrations", params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq("Registration success")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          users: {
            email: "invalid_email",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "returns validation errors" do
        post "/registrations", params: invalid_params

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("email is invalid, name can't be blank")
      end
    end
  end

  describe "POST /sessions" do
    let!(:user) { create(:user, email: "test@example.com", password: "password") }

    context "with valid credentials" do
      let(:valid_credentials) do
        {
          email: "test@example.com",
          password: "password"
        }
      end

      it "returns a token" do
        post "/sessions", params: valid_credentials

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["auth_token"]).to be_present
      end
    end

    context "with invalid credentials" do
      let(:invalid_credentials) do
        {
          email: "test@example.com",
          password: "wrong_password"
        }
      end

      it "returns an error" do
        post "/sessions", params: invalid_credentials

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Incorrect Email Or password")
      end
    end
  end
end
