FactoryBot.define do
  factory :shared do
    # các thuộc tính của shared
    url { "https://www.youtube.com/watch?v=4GjXSI6jcLI" }
    title { "Video title" }
    description { "Video description" }
    upvote { 0 }
    downvote { 0 }
    association :user
  end
end