FactoryBot.define do
  factory :message do
    association :conversation
    user { conversation.sender }
    body { "Hey, have you tried this place?" }

    trait :with_shop do
      association :shareable, factory: :chicken_shop
    end

    trait :with_review do
      association :shareable, factory: :review
      body { nil }
    end
  end
end
