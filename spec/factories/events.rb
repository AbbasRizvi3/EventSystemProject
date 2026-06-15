FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "Event #{n}" }
    description { "A test event description" }
    location { "Test Location" }
    start_time { 1.day.from_now }
    end_time { 2.days.from_now }
    capacity { 10 }
    status { "active" }
    association :user

    trait :cancelled do
      status { "cancelled" }
    end

    trait :full do
      capacity { 1 }
    end
  end
end
