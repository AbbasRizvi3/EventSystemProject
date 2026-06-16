FactoryBot.define do
  factory :wait_list_entry do
    association :user
    association :event
    position { 1 }
  end
end
