require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
      expect(user).to be_valid
    end

    it "is not valid without a name" do
      user = User.new(email: "john@example.com", password: "password", password_confirmation: "password")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it "is not valid without an email" do
      user = User.new(name: "John Doe", password: "password", password_confirmation: "password")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is not valid with an invalid email format" do
      user = User.new(name: "John Doe", email: "john@example", password: "password", password_confirmation: "password")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it "is not valid without a password" do
      user = User.new(name: "John Doe", email: "john@example.com", password_confirmation: "password")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it "is not valid without matching password confirmation" do
      user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "differentpassword")
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it "is not valid with a password less than 6 characters" do
      user = User.new(name: "John Doe", email: "john@example.com", password: "pass", password_confirmation: "pass")
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "is not valid with a password greater than 40 characters" do
      user = User.new(name: "John Doe", email: "john@example.com", password: "a" * 41, password_confirmation: "a" * 41)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too long (maximum is 40 characters)")
    end
  end

  describe "associations" do
    it "has many shareds" do
      user = User.new(name: "John Doe", email: "john@example.com", password: "password", password_confirmation: "password")
      expect(user.shareds).to eq([])
    end
  end
end