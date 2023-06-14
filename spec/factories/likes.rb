FactoryBot.define do
  factory :like do
    is_like { true }
    association :user
    association :shared
  end
end
