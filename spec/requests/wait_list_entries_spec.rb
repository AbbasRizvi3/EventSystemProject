require "rails_helper"

RSpec.describe "WaitListEntries", type: :request do
  let(:attendee_role)  { create(:role, :attendee) }
  let(:organizer_role) { create(:role, :organizer) }

  let(:attendee) do
    user = create(:user)
    user.roles << attendee_role
    user
  end

  let(:organizer) do
    user = create(:user)
    user.roles << organizer_role
    user
  end

  # A full event (capacity 1, already has one registration)
  let(:full_event) do
    event = create(:event, user: organizer, capacity: 1)
    other = create(:user)
    create(:registration, user: other, event: event)
    event
  end

  describe "POST /events/:event_id/waitlist_entries" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        post event_waitlist_entries_path(full_event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "joins the waitlist for a full event" do
        expect { post event_waitlist_entries_path(full_event) }.to change(WaitListEntry, :count).by(1)
        expect(response).to redirect_to(event_path(full_event))
      end

      it "does not allow joining the waitlist twice" do
        create(:wait_list_entry, user: attendee, event: full_event, position: 1)
        expect { post event_waitlist_entries_path(full_event) }.not_to change(WaitListEntry, :count)
      end

      it "does not allow joining the waitlist for a cancelled event" do
        cancelled = create(:event, :cancelled, user: organizer)
        expect { post event_waitlist_entries_path(cancelled) }.not_to change(WaitListEntry, :count)
      end
    end
  end

  describe "DELETE /events/:event_id/waitlist_entries/:id" do
    context "when signed in as attendee" do
      before { sign_in attendee }

      it "leaves the waitlist" do
        entry = create(:wait_list_entry, user: attendee, event: full_event, position: 1)
        expect { delete event_waitlist_entry_path(full_event, entry) }.to change(WaitListEntry, :count).by(-1)
        expect(response).to redirect_to(event_path(full_event))
      end

      it "cannot remove another user's waitlist entry" do
        other = create(:user)
        other.roles << attendee_role
        entry = create(:wait_list_entry, user: other, event: full_event, position: 1)
        expect { delete event_waitlist_entry_path(full_event, entry) }.not_to change(WaitListEntry, :count)
      end
    end
  end
end
