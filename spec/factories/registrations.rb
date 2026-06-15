FactoryBot.define do
  factory :registration do
    association :user
    association :event
    status { "confirmed" }

    trait :cancelled do
      status { "cancelled" }
    end
  end
end
