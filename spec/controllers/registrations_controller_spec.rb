require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe "POST #create" do
    context "when valid user params are provided" do
      let(:valid_params) do
        {
          users: {
            name: "John Doe",
            email: "john@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "creates a new user" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "returns a success response" do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it "returns the success message" do
        post :create, params: valid_params
        expect(JSON.parse(response.body)["success"]).to eq("Registration success")
      end
    end

    context "when invalid user params are provided" do
      let(:invalid_params) do
        {
          users: {
            name: "",
            email: "invalid_email",
            password: "short",
            password_confirmation: "different"
          }
        }
      end

      it "does not create a new user" do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it "returns an bad_request response" do
        post :create, params: invalid_params
        expect(response).to have_http_status(:bad_request)
      end

      it "returns the error messages" do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)["error"]).to(
          include("password_confirmation doesn't match Password, email is invalid, password is too short (minimum is 6 characters), name can't be blank")
        )
      end
    end
  end
end
