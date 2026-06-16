require "rails_helper"

RSpec.describe "Users", type: :request do
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

  let(:target_user) { create(:user) }

  describe "GET /users" do
    context "when unauthenticated" do
      it "redirects to sign in" do
        get users_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get users_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when signed in as admin" do
      before { sign_in admin }

      it "returns 200" do
        get users_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /users/:id" do
    context "when signed in as admin" do
      before { sign_in admin }

      it "returns 200" do
        get user_path(target_user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as attendee viewing own profile" do
      before { sign_in attendee }

      it "returns 200" do
        get user_path(attendee)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /users/admin_create" do
    let(:valid_params) do
      { user: { name: "New User", email: "newuser@example.com", roles: [ "attendee" ] } }
    end

    context "when signed in as admin" do
      before { sign_in admin }

      it "creates a new user" do
        expect { post admin_create_users_path, params: valid_params }.to change(User, :count).by(1)
        expect(response).to redirect_to(users_path)
      end

      it "does not create a user without a role" do
        # Omitting roles entirely simulates a form submitted with no role checked
        params = { user: { name: "No Role", email: "norole@example.com" } }
        expect { post admin_create_users_path, params: params }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not allow combining admin with other roles" do
        params = { user: { name: "Bad Role", email: "bad@example.com", roles: [ "admin", "attendee" ] } }
        expect { post admin_create_users_path, params: params }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        post admin_create_users_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /users/:id" do
    context "when signed in as admin" do
      before { sign_in admin }

      it "deletes the user" do
        user_to_delete = target_user
        expect { delete user_path(user_to_delete) }.to change(User, :count).by(-1)
        expect(response).to redirect_to(users_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        delete user_path(target_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /users/new" do
    context "when signed in as admin" do
      before { sign_in admin }

      it "returns 200" do
        get new_user_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        get new_user_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /users/:id/update_roles" do
    context "when signed in as admin" do
      before { sign_in admin }

      it "updates the user roles and redirects" do
        patch update_roles_user_path(target_user), params: { role_names: [ "organizer" ] }
        expect(response).to redirect_to(user_path(target_user))
      end

      it "rejects admin combined with other roles" do
        patch update_roles_user_path(target_user), params: { role_names: [ "admin", "attendee" ] }
        expect(response).to redirect_to(user_path(target_user))
        expect(flash[:alert]).to include("Admin role cannot be combined")
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "redirects (not authorized)" do
        patch update_roles_user_path(target_user), params: { role_names: [ "organizer" ] }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
