require "rails_helper"

RSpec.describe NotificationJob, type: :job do
  let!(:user) { create(:user) }

  before do
    allow(NotificationMailer).to receive_message_chain(:notify, :deliver_later)
    allow(ActionCable.server).to receive(:broadcast)
  end

  describe "#perform" do
    it "creates a notification for the user" do
      expect {
        described_class.perform_now(user.id, "Hello", "World", "registration")
      }.to change(user.notifications, :count).by(1)
    end

    it "sets the correct title, body, and notification_type" do
      described_class.perform_now(user.id, "Title", "Body text", "waitlist")
      notification = user.notifications.last
      expect(notification.title).to eq("Title")
      expect(notification.body).to eq("Body text")
      expect(notification.notification_type).to eq("waitlist")
    end

    it "sends a notification email" do
      expect(NotificationMailer).to receive_message_chain(:notify, :deliver_later)
      described_class.perform_now(user.id, "Hello", "World", "registration")
    end

    it "broadcasts to the notification channel" do
      expect(ActionCable.server).to receive(:broadcast)
      described_class.perform_now(user.id, "Hello", "World", "registration")
    end
  end

  describe "queuing" do
    it "is queued on the default queue" do
      expect(described_class.queue_name).to eq("default")
    end

    it "can be enqueued" do
      expect {
        described_class.perform_later(user.id, "Hello", "World", "registration")
      }.to have_enqueued_job(described_class)
    end
  end
end
