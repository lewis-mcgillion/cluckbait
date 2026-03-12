FactoryBot.define do
  factory :review do
    association :user
    association :chicken_shop
    rating { 4 }
    title { "Great chicken burger" }
    body { "Really enjoyed the crispy coating and juicy inside. Would recommend." }

    trait :five_stars do
      rating { 5 }
      title { "Absolutely outstanding" }
      body { "Best chicken burger I have ever had." }
    end

    trait :one_star do
      rating { 1 }
      title { "Disappointing" }
      body { "Cold burger, slow service, would not return." }
    end

    trait :three_stars do
      rating { 3 }
      title { "Decent but nothing special" }
      body { "Average chicken burger. Nothing wrong but nothing memorable." }
    end

    trait :with_long_title do
      title { "a" * 101 }
    end

    trait :with_long_body do
      body { "a" * 2001 }
    end
  end
end
