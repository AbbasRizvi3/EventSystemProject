require "rails_helper"

RSpec.describe "Events", type: :request do
  let(:admin_role)     { create(:role, :admin) }
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:admin) do
    user = create(:user)
    user.roles << admin_role
    user
  end

  let(:organizer) do
    user = create(:user)
    user.roles << organizer_role
    user
  end

  let(:attendee) do
    user = create(:user)
    user.roles << attendee_role
    user
  end

  let(:event) { create(:event, user: organizer) }

  describe "GET /events" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get events_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns 200" do
        get events_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as organizer" do
      before { sign_in organizer }

      it "returns 200" do
        get events_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /events/:id" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get event_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns 200" do
        get event_path(event)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /events/new" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get new_event_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get new_event_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed in as organizer" do
      before { sign_in organizer }

      it "returns 200" do
        get new_event_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as admin" do
      before { sign_in admin }

      it "returns 200" do
        get new_event_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /events" do
    let(:valid_params) do
      { event: { title: "New Event", location: "City Hall", description: "Details",
                 start_time: 1.day.from_now, end_time: 2.days.from_now, capacity: 50 } }
    end

    context "when unauthenticated" do
      it "redirects to sign in" do
        post events_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "does not create event and redirects" do
        expect { post events_path, params: valid_params }.not_to change(Event, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed in as organizer" do
      before { sign_in organizer }

      it "creates an event and redirects" do
        expect { post events_path, params: valid_params }.to change(Event, :count).by(1)
        expect(response).to redirect_to(event_path(Event.last))
      end

      it "does not create event with invalid params" do
        expect { post events_path, params: { event: { title: "" } } }.not_to change(Event, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /events/:id/cancel" do
    context "when signed in as organizer (event owner)" do
      before { sign_in organizer }

      it "cancels the event" do
        patch cancel_event_path(event)
        expect(event.reload).to be_cancelled
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "does not cancel event and redirects" do
        patch cancel_event_path(event)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /events/:id" do
    context "when signed in as admin" do
      before { sign_in admin }

      it "deletes the event" do
        event_to_delete = event
        expect { delete event_path(event_to_delete) }.to change(Event, :count).by(-1)
      end
    end

    context "when signed in as organizer" do
      before do
        sign_in organizer
        event # force creation before the expect block
      end

      it "does not delete event and redirects" do
        expect { delete event_path(event) }.not_to change(Event, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /events/:id/edit" do
    context "when signed in as organizer (event owner)" do
      before { sign_in organizer }

      it "returns 200" do
        get edit_event_path(event)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get edit_event_path(event)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /events/:id" do
    let(:update_params) { { event: { title: "Updated Title", location: "New Location", description: "Updated desc", start_time: 1.day.from_now, end_time: 2.days.from_now, capacity: 20 } } }

    context "when signed in as organizer (event owner)" do
      before { sign_in organizer }

      it "updates the event and redirects" do
        patch event_path(event), params: update_params
        expect(event.reload.title).to eq("Updated Title")
        expect(response).to redirect_to(event_path(event))
      end

      it "does not update with invalid params" do
        patch event_path(event), params: { event: { title: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        patch event_path(event), params: update_params
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /events/registered_events" do
    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns 200" do
        get registered_events_events_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as organizer" do
      before { sign_in organizer }

      it "redirects (not authorized)" do
        get registered_events_events_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /events/waitlisted_events" do
    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns 200" do
        get waitlisted_events_events_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as organizer" do
      before { sign_in organizer }

      it "redirects (not authorized)" do
        get waitlisted_events_events_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /events/created_events" do
    context "when signed in as organizer" do
      before { sign_in organizer }

      it "returns 200" do
        get created_events_events_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get created_events_events_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
