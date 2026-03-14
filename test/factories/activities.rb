FactoryBot.define do
  factory :activity do
    association :user
    action { "posted_review" }

    trait :review_activity do
      action { "posted_review" }
      association :trackable, factory: :review
    end

    trait :friendship_activity do
      action { "became_friends" }
      association :trackable, factory: [:friendship, :accepted]
    end
  end
end
