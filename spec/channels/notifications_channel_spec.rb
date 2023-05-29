require 'rails_helper'

RSpec.describe NotificationsChannel, type: :channel do
  let!(:user) { create(:user) }
  let!(:encoded_token) { JsonWebTokenService.encode({ email: user.email }) }

  it 'subscribes successfully with valid token' do
    subscribe(jwt: encoded_token)
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from('NotificationsChannel')
    expect(subscription).to have_stream_for(user)
  end

  it 'rejects subscription with invalid token' do
    subscribe(jwt: 'invalid_token')
    expect(subscription).to be_rejected
  end

  it 'rejects subscription without token' do
    subscribe
    expect(subscription).to be_rejected
  end

  it 'unsubscribes successfully' do
    subscribe(jwt: encoded_token)
    unsubscribe
    expect(subscription).to be_rejected
  end

end
