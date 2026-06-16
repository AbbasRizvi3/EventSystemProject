FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    # skip_default_role prevents the after_commit callback from assigning the
    # attendee role automatically, keeping tests isolated from role seeding
    skip_default_role { true }
  end
end
