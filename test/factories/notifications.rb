FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    action { "friend_request" }
    notifiable { association :friendship }

    trait :friend_request do
      action { "friend_request" }
      notifiable { association :friendship }
    end

    trait :friend_accepted do
      action { "friend_accepted" }
      notifiable { association :friendship, :accepted }
    end

    trait :new_message do
      action { "new_message" }
      notifiable { association :message }
    end

    trait :read do
      read_at { Time.current }
    end

    trait :unread do
      read_at { nil }
    end
  end
end
