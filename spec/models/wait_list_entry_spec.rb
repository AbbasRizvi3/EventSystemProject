require "rails_helper"

RSpec.describe WaitListEntry, type: :model do
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:organizer) { user = create(:user); user.roles << organizer_role; user }
  let(:attendee)  { user = create(:user); user.roles << attendee_role; user }
  let(:full_event) do
    event = create(:event, user: organizer, capacity: 1)
    create(:registration, event: event)
    event
  end

  subject(:entry) { build(:wait_list_entry, user: attendee, event: full_event, position: 1) }

  describe "associations" do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position).is_greater_than(0) }

    it "is invalid when the same user joins the waitlist twice" do
      create(:wait_list_entry, user: attendee, event: full_event, position: 1)
      duplicate = build(:wait_list_entry, user: attendee, event: full_event, position: 2)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("is already on the waitlist for this event")
    end
  end

  describe "custom validations" do
    context "when event is cancelled" do
      before { full_event.update!(status: :cancelled) }

      it "is invalid" do
        expect(entry).not_to be_valid
        expect(entry.errors[:base]).to include("Cannot join waitlist for a cancelled event.")
      end
    end

    context "when event still has spots available" do
      let(:available_event) { create(:event, user: organizer, capacity: 10) }

      it "is invalid" do
        entry = build(:wait_list_entry, user: attendee, event: available_event, position: 1)
        expect(entry).not_to be_valid
        expect(entry.errors[:base]).to include("Event still has spots available. Please register instead.")
      end
    end

    context "when user is already registered for the event" do
      before { create(:registration, user: attendee, event: full_event, status: :confirmed) }

      it "is invalid" do
        expect(entry).not_to be_valid
        expect(entry.errors[:base]).to include("You are already registered for this event.")
      end
    end
  end
end
