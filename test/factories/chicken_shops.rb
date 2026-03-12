FactoryBot.define do
  factory :chicken_shop do
    sequence(:name) { |n| "Chicken Shop #{n}" }
    sequence(:address) { |n| "#{n} High Street" }
    city { "London" }
    postcode { "SW1A 1AA" }
    latitude { 51.5074 }
    longitude { -0.1278 }
    description { "A great chicken shop" }
    phone { "020 1234 5678" }
    website { "https://example.com" }

    trait :in_northampton do
      name { "Sam's Chicken" }
      address { "123 High Street" }
      city { "Northampton" }
      postcode { "NN1 2AA" }
      latitude { 52.2405 }
      longitude { -0.9027 }
    end

    trait :in_manchester do
      name { "Wing Stop" }
      address { "10 Market Street" }
      city { "Manchester" }
      postcode { "M1 1PT" }
      latitude { 53.4808 }
      longitude { -2.2426 }
    end

    trait :in_birmingham do
      name { "New Cluckers" }
      address { "1 Empty Lane" }
      city { "Birmingham" }
      postcode { "B1 1AA" }
      latitude { 52.4862 }
      longitude { -1.8904 }
    end

    trait :without_postcode do
      postcode { nil }
    end
  end
end
