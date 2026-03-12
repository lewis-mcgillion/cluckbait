FactoryBot.define do
  factory :review_reaction do
    association :user
    association :review
    kind { "thumbs_up" }

    trait :fire do
      kind { "fire" }
    end

    trait :thumbs_up do
      kind { "thumbs_up" }
    end

    trait :heart_eyes do
      kind { "heart_eyes" }
    end

    trait :laugh do
      kind { "laugh" }
    end

    trait :helpful do
      kind { "helpful" }
    end

    trait :not_helpful do
      kind { "not_helpful" }
    end
  end
end
