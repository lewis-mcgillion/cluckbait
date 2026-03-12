FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    display_name { "TestUser" }
    bio { "I love chicken burgers" }

    trait :without_display_name do
      display_name { "" }
    end

    trait :with_long_display_name do
      display_name { "a" * 51 }
    end

    trait :with_long_bio do
      bio { "a" * 501 }
    end
  end
end
