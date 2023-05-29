FactoryBot.define do
  factory :shared do
    # các thuộc tính của shared
    url { "https://www.youtube.com/watch?v=4GjXSI6jcLI" }
    association :user
  end
end