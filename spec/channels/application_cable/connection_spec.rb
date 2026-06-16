require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  let(:user) { create(:user) }

  it "connects with a verified user" do
    connect "/cable", env: { "warden" => double("warden", user: user) }
    expect(connection.current_user).to eq(user)
  end

  it "rejects connection without a user" do
    expect {
      connect "/cable", env: { "warden" => double("warden", user: nil) }
    }.to have_rejected_connection
  end
end
