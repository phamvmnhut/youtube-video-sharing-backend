RSpec.describe LikesController, type: :controller do
  describe 'POST #create' do
    let!(:user) { create(:user) }
    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    let!(:shared) { create(:shared) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
    end

    context 'with valid parameters' do
      it 'creates a new like' do
        post :create, params: { shared_id: shared.id, is_like: true }, session: { user_id: user.id }
        expect(response).to have_http_status(:created)

        parsed_response = JSON.parse(response.body)

        expect(parsed_response["data"]["id"]).to eq(Like.last.id)
        expect(parsed_response["data"]["user_id"]).to eq(user.id)
        expect(parsed_response["data"]["shared_id"]).to eq(shared.id)
        expect(parsed_response["data"]["is_like"]).to eq(true)
      end
    end

    context 'with invalid parameters' do
      it 'returns an error when shared_id is invalid' do
        post :create, params: { shared_id: 999, is_like: true }, session: { user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({
          'error' => 'Invalid shared_id'
        })
      end

      it 'returns an error when is_like parameter is missing' do
        post :create, params: { shared_id: shared.id }, session: { user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({
          'error' => 'is_like parameter is missing'
        })
      end

      it 'returns an error when like already exists' do
        create(:like, shared: shared, user: user)

        post :create, params: { shared_id: shared.id, is_like: true }, session: { user_id: user.id }
        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)).to eq({
          'error' => 'Like already exists. Please use the update method instead.'
        })
      end

      it 'returns an error when parameters are invalid' do
        post :create, params: { shared_id: nil, is_like: nil }, session: { user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({
          'error' => "Invalid shared_id"
        })
      end
    end
  end

  describe 'GET #show' do
    let!(:user) { create(:user) }
    let!(:shared) { create(:shared, user: user) }
    let!(:like) { create(:like, user: user, shared: shared) }

    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
    end

    context 'when like is found' do
      before do
        get :show, params: { id: like.id }, session: { user_id: user.id }
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the like data' do
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq('Like found')
        expect(json_response['data']['id']).to eq(like.id)
      end
    end

    context 'when like is not found' do
      before do
        get :show, params: { id: 123 }, session: { user_id: user.id }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Like not found')
      end
    end
  end

  describe 'PATCH #update' do
    let!(:user) { create(:user) }
    let!(:shared) { create(:shared, user: user) }
    let!(:like) { create(:like, user: user, shared: shared) }

    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
    end

    context 'when like is found' do
      before do
        patch :update, params: { id: like.id }, session: { user_id: user.id }
      end

      it 'toggles the is_like attribute' do
        is_like_old = like.is_like
        like.reload
        expect(like.is_like).to eq(!is_like_old)
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated like data' do
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq('Like updated successfully.')
        expect(json_response['data']['id']).to eq(like.id)
      end
    end

    context 'when like is not found' do
      before do
        patch :update, params: { id: 123 }, session: { user_id: user.id }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Like not found.')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }
    let!(:like) { create(:like, user: user) }

    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
    end

    context 'when like is found and owned by current user' do
      it 'deletes the like' do
        expect {
          delete :destroy, params: { id: like.id }, session: { user_id: user.id }
        }.to change(Like, :count).by(-1)
      end

      it 'returns success status' do
        delete :destroy, params: { id: like.id }, session: { user_id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns success message' do
        delete :destroy, params: { id: like.id }, session: { user_id: user.id }
        expect(JSON.parse(response.body)).to eq({ 'success' => 'Like deleted successfully' })
      end
    end

    context 'when like is not found or not owned by current user' do
      it 'returns not found status' do
        delete :destroy, params: { id: 123 }, session: { user_id: user.id }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        delete :destroy, params: { id: 123 }, session: { user_id: user.id }
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Like not found or not owned by current user' })
      end
    end
  end

  describe 'GET #show_by_shared' do
    let!(:user) { create(:user) }
    let!(:shared) { create(:shared) }
    let!(:like) { create(:like, user: user, shared: shared) }

    let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
      request.headers.merge!(HTTP_AUTH_TOKEN: auth_token)
    end

    context 'when like is found' do
      it 'returns success status' do
        get :show_by_shared, params: { shared_id: shared.id }, session: { user_id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the like data' do
        get :show_by_shared, params: { shared_id: shared.id }, session: { user_id: user.id }
        expect(JSON.parse(response.body)).to eq({ 'success' => 'Like found', 'data' => like.as_json })
      end
    end

    context 'when like is not found' do
      it 'returns not found status' do
        get :show_by_shared, params: { shared_id: 123 }, session: { user_id: user.id }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        get :show_by_shared, params: { shared_id: 123 }, session: { user_id: user.id }
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Like not found' })
      end
    end
  end
end
