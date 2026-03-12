FactoryBot.define do
  factory :wishlist_item do
    association :user
    association :chicken_shop
    visited { false }
    notes { nil }

    trait :visited do
      visited { true }
    end

    trait :with_notes do
      notes { "Heard great things about their spicy wings!" }
    end
  end
end
