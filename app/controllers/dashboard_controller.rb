class DashboardController < ApplicationController
  include AdminAuthorizable
  before_action :authenticate_user!
  before_action :authorize_admin

  def index
    authorize :dashboard, :index?
    @registrations = policy_scope(Registration).includes(:user, :event).order(created_at: :desc).page(params[:page]).per(15)
    @waitlist_entries = policy_scope(WaitListEntry).includes(:user, :event).order(:event_id, :position).page(params[:page]).per(15)
  end
end
