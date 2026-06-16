require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:user) { create(:user, email: "recipient@example.com", name: "Alice") }

  describe "#notify" do
    let(:mail) { described_class.notify(user, "Event Registered", "You have been registered.") }

    it "renders the subject" do
      expect(mail.subject).to eq("Event Registered")
    end

    it "sends to the user's email address" do
      expect(mail.to).to eq([ "recipient@example.com" ])
    end

    it "includes the notification body in the email" do
      expect(mail.body.encoded).to include("You have been registered.")
    end
  end
end
