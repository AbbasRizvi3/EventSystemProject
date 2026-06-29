require "rails_helper"

RSpec.describe Registration, type: :model do
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:organizer) { user = create(:user); user.roles << organizer_role; user }
  let(:attendee)  { user = create(:user); user.roles << attendee_role; user }
  let(:event)     { create(:event, user: organizer, capacity: 5) }

  subject(:registration) { build(:registration, user: attendee, event: event) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }

    it "is invalid when the same user registers for the same event twice" do
      create(:registration, user: attendee, event: event)
      duplicate = build(:registration, user: attendee, event: event)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already registered for this event")
    end
  end

  describe "custom validations" do
    context "when event is cancelled" do
      before { event.update!(status: :cancelled) }

      it "is invalid" do
        expect(registration).not_to be_valid
        expect(registration.errors[:base]).to include("Cannot register for a cancelled event.")
      end
    end

    context "when event is full" do
      before do
        create_list(:registration, 5, event: event)
      end

      it "is invalid" do
        expect(registration).not_to be_valid
        expect(registration.errors[:base]).to include("Event is full. Join the waitlist.")
      end
    end
  end

  describe "scopes" do
    it ".confirmed returns only confirmed registrations" do
      confirmed = create(:registration, user: attendee, event: event, status: :confirmed)
      cancelled = create(:registration, user: create(:user), event: event, status: :cancelled)
      expect(Registration.confirmed).to include(confirmed)
      expect(Registration.confirmed).not_to include(cancelled)
    end
  end
end
