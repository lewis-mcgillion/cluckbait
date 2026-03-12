FactoryBot.define do
  factory :conversation do
    sender { association :user }
    receiver { association :user }
  end
end
