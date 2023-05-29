FactoryBot.define do
  factory :user do
    # các thuộc tính của user
    name { "John Doe" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end