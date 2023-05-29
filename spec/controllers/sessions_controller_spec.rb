require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    let!(:user) { User.create(name: "John Doe", email: "test@example.com", password: "password", password_confirmation: "password") }

    context "when valid email and password are provided" do
      let(:valid_params) do
        {
          email: "test@example.com",
          password: "password"
        }
      end

      it "finds the user" do
        post :create, params: valid_params
        expect(assigns(:user)).to eq(user)
      end

      it "returns a success response" do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it "returns the authentication token and user data" do
        post :create, params: valid_params
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["auth_token"]).not_to be_nil
        expect(parsed_response["data"]).to include("email" => user.email)
      end
    end

    context "when invalid email or password are provided" do
      let(:invalid_params) do
        {
          email: "test@example.com",
          password: "wrong_password"
        }
      end

      it "does not find the user" do
        post :create, params: invalid_params
        expect(assigns(:user)).to be_nil
      end

      it "returns an unauthorized response" do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns the error message" do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)["error"]).to eq("Incorrect Email Or password")
      end
    end
  end
end
