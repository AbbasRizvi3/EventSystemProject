FactoryBot.define do
  factory :notification do
    association :user
    title { "Test Notification" }
    body { "This is a test notification body" }
    notification_type { "registration" }
  end
end
