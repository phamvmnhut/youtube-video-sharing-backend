require 'rails_helper'

RSpec.describe AuthenticateHelper, type: :helper do
  let!(:user) { create(:user) }
  let!(:auth_token) { JsonWebTokenService.encode({ email: user.email }) }
  let!(:request) { double('request').as_null_object }

  before do
    allow(request).to receive(:headers).and_return({ 'HTTP_AUTH_TOKEN' => auth_token })
    helper.request = request
  end

  describe '#authenticate_user' do
    context 'when the user is authenticated' do
      it 'sets the current user' do
        helper.authenticate_user
        expect(helper.current_user).to eq(user)
      end
    end

    # context 'when the user is not authenticated' do
    #   let(:auth_token) { 'invalid_token' }
    #   it 'returns unauthorized status' do
    #     helper.authenticate_user
    #     expect(helper.current_user).to be_nil
    #   end
    # end
  end

  describe '#user_sign_in?' do
    context 'when the user is signed in' do
      it 'returns true' do
        helper.authenticate_user
        expect(helper.user_sign_in?).to be_truthy
      end
    end

    context 'when the user is not signed in' do
      before do
        helper.instance_variable_set(:@current_user, nil)
      end

      it 'returns false' do
        expect(helper.user_sign_in?).to be_falsey
      end
    end
  end
end
