FactoryBot.define do
  factory :friendship do
    user { association :user }
    friend { association :user }
    status { "pending" }

    trait :accepted do
      status { :accepted }
    end
  end
end
