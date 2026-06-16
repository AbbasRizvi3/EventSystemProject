require "rails_helper"

RSpec.describe "Registrations", type: :request do
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

  let(:event) { create(:event, user: organizer, capacity: 5) }

  describe "POST /events/:event_id/registrations" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        post event_registrations_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "creates a registration" do
        expect { post event_registrations_path(event) }.to change(Registration, :count).by(1)
        expect(response).to redirect_to(event_path(event))
      end

      it "does not allow registering twice for the same event" do
        create(:registration, user: attendee, event: event)
        expect { post event_registrations_path(event) }.not_to change(Registration, :count)
      end

      it "does not allow registering for a cancelled event" do
        cancelled_event = create(:event, :cancelled, user: organizer)
        expect { post event_registrations_path(cancelled_event) }.not_to change(Registration, :count)
      end

      it "does not allow registering for a full event" do
        full_event = create(:event, user: organizer, capacity: 1)
        create(:registration, event: full_event)
        expect { post event_registrations_path(full_event) }.not_to change(Registration, :count)
      end
    end
  end

  describe "GET /events/:event_id/registrations" do
    let(:admin_role) { create(:role, :admin) }
    let(:admin) { user = create(:user); user.roles << admin_role; user }

    context "when signed in as admin" do
      before { sign_in admin }

      it "is authorized (policy allows access)" do
        get event_registrations_path(event)
        expect(response).not_to redirect_to(root_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get event_registrations_path(event)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /events/:event_id/registrations/:id" do
    context "when signed in as attendee" do
      before { sign_in attendee }

      it "cancels the registration" do
        registration = create(:registration, user: attendee, event: event)
        delete event_registration_path(event, registration)
        expect(registration.reload.status).to eq("cancelled")
        expect(response).to redirect_to(event_path(event))
      end

      it "cannot cancel another user's registration" do
        other_attendee   = create(:user)
        other_attendee.roles << attendee_role
        other_registration = create(:registration, user: other_attendee, event: event)
        expect { delete event_registration_path(event, other_registration) }.not_to change(Registration, :count)
      end
    end
  end
end
