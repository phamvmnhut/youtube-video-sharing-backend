require 'rails_helper'

RSpec.describe Shared, type: :model do
  describe "validations" do
    it "is valid with a valid url format" do
      shared = Shared.new(user: User.new, url: "http://www.youtube.com/watch?v=ABC123", title: "Video title", description: "Video description")
      expect(shared).to be_valid
    end

    it "is not valid without a user" do
      shared = Shared.new(url: "http://www.youtube.com/watch?v=ABC123")
      expect(shared).not_to be_valid
      expect(shared.errors[:user]).to include("must exist")
    end

    it "is not valid without a url" do
      shared = Shared.new(user: User.new)
      expect(shared).not_to be_valid
      expect(shared.errors[:url]).to include("can't be blank")
    end

    it "is not valid with an invalid url format" do
      shared = Shared.new(user: User.new, url: "invalid_url")
      expect(shared).not_to be_valid
      expect(shared.errors[:url]).to include("is invalid")
    end

    it "is not valid without a title" do
      shared = Shared.new(user: User.new)
      expect(shared).not_to be_valid
      expect(shared.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a description" do
      shared = Shared.new(user: User.new)
      expect(shared).not_to be_valid
      expect(shared.errors[:description]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
      shared = Shared.new(user: user, url: "http://www.youtube.com/watch?v=ABC123")
      expect(shared.user).to eq(user)
    end

    it "has many shareds" do
      user = User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
      shared1 = Shared.create(user: user, url: "http://www.youtube.com/watch?v=ABC123", title: "Video title", description: "Video desciption")
      shared2 = Shared.create(user: user, url: "http://www.youtube.com/watch?v=DEF456", title: "Video title", description: "Video desciption")

      expect(user.shareds.count).to eq(2)
      expect(user.shareds).to include(shared1, shared2)
    end

    it "does not have any shareds" do
      user = User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")

      expect(user.shareds).to be_empty
    end

    it "does not have a specific shared" do
      user1 = User.create(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
      user2 = User.create(name: "Jane Smith", email: "jane@example.com", password: "password", password_confirmation: "password")
      shared = Shared.create(user: user2, url: "http://www.youtube.com/watch?v=ABC123")

      expect(user1.shareds).not_to include(shared)
    end
  end

  describe 'after_create_commit' do
    let!(:redis) { MockRedis.new }

    before do
      allow(Redis).to receive(:new).and_return(redis)
    end

    let!(:user) { create(:user) }
    let!(:shared) { build(:shared, user: user) }

    it 'queues a SendNotificationJob after creation' do
      expect {
        shared.save
      }.to have_enqueued_job(SendNotificationJob)
        .with(anything, shared.url, shared.title, user.name, user.email)
        .on_queue(:default)
    end

    it 'sends a notification to the user' do
      allow(SendNotificationJob).to receive(:perform_later)

      shared.save

      expect(SendNotificationJob).to have_received(:perform_later)
        .with(shared.id, shared.url, shared.title, user.name, user.email)
    end

  end

end