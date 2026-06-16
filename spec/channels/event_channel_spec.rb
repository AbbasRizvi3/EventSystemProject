require "rails_helper"

RSpec.describe EventChannel, type: :channel do
  let(:user) { create(:user) }
  let(:event) { create(:event, user: user) }

  before { stub_connection current_user: user }

  it "subscribes and streams for a valid event" do
    subscribe event_id: event.id
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(event)
  end

  it "rejects subscription for an invalid event id" do
    subscribe event_id: 0
    expect(subscription).to be_rejected
  end
end
