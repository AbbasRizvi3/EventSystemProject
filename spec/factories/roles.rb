FactoryBot.define do
  factory :role do
    name { "attendee" }

    # Roles are seeded (admin/organizer/attendee always exist in the DB).
    # find_or_initialize_by prevents duplicate-name errors in tests.
    initialize_with { Role.find_or_initialize_by(name: name) }

    trait :admin do
      name { "admin" }
    end

    trait :organizer do
      name { "organizer" }
    end

    trait :attendee do
      name { "attendee" }
    end
  end
end
