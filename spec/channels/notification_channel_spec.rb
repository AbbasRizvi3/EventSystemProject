require "rails_helper"

RSpec.describe NotificationChannel, type: :channel do
  let(:user) { create(:user) }

  before { stub_connection current_user: user }

  it "subscribes and streams for current user" do
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(user)
  end
end
