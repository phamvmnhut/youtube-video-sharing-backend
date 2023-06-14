require 'rails_helper'

RSpec.describe Like, type: :model do
  let!(:user) { create(:user) }
  let!(:shared) { create(:shared) }

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to shared' do
      association = described_class.reflect_on_association(:shared)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'after_create' do
    it 'increments upvote when like is created with is_like = true' do
      expect {
        create(:like, user: user, shared: shared, is_like: true)
      }.to change { shared.reload.upvote }.by(1)
    end

    it 'increments downvote when like is created with is_like = false' do
      expect {
        create(:like, user: user, shared: shared, is_like: false)
      }.to change { shared.reload.downvote }.by(1)
    end
  end

  describe 'after_update' do
    it 'increments upvote and decrements downvote when is_like changes from false to true' do
      expect {
        like = create(:like, user: user, shared: shared, is_like: false)
        like.update(is_like: true)
        shared.reload
      }.to change { shared.upvote }.by(1)
       .and change { shared.downvote }.by(0)
    end

    it 'decrements upvote and increments downvote when is_like changes from true to false' do
      expect {
        like = create(:like, user: user, shared: shared, is_like: true)
        like.update(is_like: false)
        shared.reload
      }.to change { shared.upvote }.by(0)
       .and change { shared.downvote }.by(1)
    end
  end

  describe 'after_destroy' do
    it 'decrements upvote when like is destroyed and is_like = true' do
      expect {
        like = create(:like, user: user, shared: shared, is_like: true)
        like.destroy
        shared.reload
      }.to change { shared.upvote }.by(0)
    end

    it 'decrements downvote when like is destroyed and is_like = false' do
      expect {
        like = create(:like, user: user, shared: shared, is_like: false)
        like.destroy
        shared.reload
      }.to change { shared.downvote }.by(0)
    end
  end
end
