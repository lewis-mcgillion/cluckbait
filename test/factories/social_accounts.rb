FactoryBot.define do
  factory :social_account do
    user
    provider { "google_oauth2" }
    sequence(:uid) { |n| "oauth-uid-#{n}" }
    sequence(:email) { |n| "social#{n}@example.com" }

    trait :google do
      provider { "google_oauth2" }
    end

    trait :apple do
      provider { "apple" }
    end

    trait :facebook do
      provider { "facebook" }
    end
  end
end
