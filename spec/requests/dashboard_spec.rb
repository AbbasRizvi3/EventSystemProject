require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:admin_role)    { create(:role, :admin) }
  let(:attendee_role) { create(:role, :attendee) }

  let(:admin) do
    user = create(:user)
    user.roles << admin_role
    user
  end

  let(:attendee) do
    user = create(:user)
    user.roles << attendee_role
    user
  end

  describe "GET /dashboard" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get dashboard_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get dashboard_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed in as admin" do
      before { sign_in admin }

      it "returns 200" do
        get dashboard_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
