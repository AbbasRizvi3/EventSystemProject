require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:attendee_role) { create(:role, :attendee) }

  let(:attendee) do
    user = create(:user)
    user.roles << attendee_role
    user
  end

  describe "GET /notifications" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get notifications_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before { sign_in attendee }

      it "returns 200" do
        get notifications_path
        expect(response).to have_http_status(:ok)
      end

      it "shows only the current user's notifications" do
        own_notification   = create(:notification, user: attendee, title: "My Personal Alert")
        _other_notification = create(:notification, title: "Someone Elses Alert")
        get notifications_path
        expect(response.body).to include("My Personal Alert")
        expect(response.body).not_to include("Someone Elses Alert")
      end
    end
  end
end
