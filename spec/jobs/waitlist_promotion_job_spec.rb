require "rails_helper"

RSpec.describe WaitlistPromotionJob, type: :job do
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:organizer) do
    user = create(:user)
    user.roles << organizer_role
    user
  end

  let(:event) { create(:event, user: organizer, capacity: 1) }

  let(:waitlisted_user) do
    user = create(:user)
    user.roles << attendee_role
    user
  end

  before do
    allow(NotificationJob).to receive(:perform_later)
    allow(ActionCable.server).to receive(:broadcast)
  end

  describe "#perform" do
    context "when there is a waitlisted user" do
      before do
        create(:wait_list_entry, user: waitlisted_user, event: event, position: 1)
      end

      it "promotes the first waitlisted user to a confirmed registration" do
        expect {
          described_class.perform_now(event.id)
        }.to change(Registration, :count).by(1)

        registration = Registration.find_by(user: waitlisted_user, event: event)
        expect(registration).to be_confirmed
      end

      it "removes the waitlist entry after promotion" do
        expect {
          described_class.perform_now(event.id)
        }.to change(WaitListEntry, :count).by(-1)
      end

      it "sends a promotion notification to the promoted user" do
        expect(NotificationJob).to receive(:perform_later).with(
          waitlisted_user.id, "You're Registered!", anything, "promotion"
        )
        described_class.perform_now(event.id)
      end
    end

    context "when the waitlist is empty" do
      it "does not create a registration" do
        expect { described_class.perform_now(event.id) }.not_to change(Registration, :count)
      end
    end

    context "when the event is cancelled" do
      before { event.update!(status: "cancelled") }

      it "does not promote anyone" do
        create(:wait_list_entry, user: waitlisted_user, event: event, position: 1)
        expect { described_class.perform_now(event.id) }.not_to change(Registration, :count)
      end
    end

    context "with multiple waitlisted users (FIFO order)" do
      let(:second_user) do
        user = create(:user)
        user.roles << attendee_role
        user
      end

      before do
        create(:wait_list_entry, user: waitlisted_user, event: event, position: 1)
        create(:wait_list_entry, user: second_user, event: event, position: 2)
      end

      it "promotes the user with the lowest position first" do
        described_class.perform_now(event.id)
        expect(Registration.find_by(user: waitlisted_user, event: event)).to be_present
        expect(Registration.find_by(user: second_user, event: event)).to be_nil
      end

      it "updates remaining waitlist positions" do
        described_class.perform_now(event.id)
        expect(second_user.wait_list_entries.find_by(event: event).position).to eq(1)
      end
    end
  end
end
