require "rails_helper"

RSpec.describe Registration, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:event) }
  end

  describe "validations" do
    it { should validate_presence_of(:status) }

    it "is valid with a user and event" do
      expect(build(:registration)).to be_valid
    end

    it "is invalid when the same user registers for the same event twice" do
      user  = create(:user)
      event = create(:event)
      create(:registration, user: user, event: event)
      duplicate = build(:registration, user: user, event: event)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already registered for this event")
    end

    it "allows different users to register for the same event" do
      event = create(:event)
      create(:registration, event: event)
      expect(build(:registration, event: event)).to be_valid
    end

    it "allows the same user to register for different events" do
      user = create(:user)
      create(:registration, user: user)
      expect(build(:registration, user: user)).to be_valid
    end
  end

  describe "status enum" do
    it "can be confirmed" do
      expect(build(:registration, status: "confirmed")).to be_confirmed
    end

    it "can be cancelled" do
      expect(build(:registration, :cancelled)).to be_cancelled
    end
  end

  describe ".confirmed scope" do
    it "includes confirmed registrations" do
      confirmed = create(:registration, status: "confirmed")
      expect(Registration.confirmed).to include(confirmed)
    end

    it "excludes cancelled registrations" do
      cancelled = create(:registration, :cancelled)
      expect(Registration.confirmed).not_to include(cancelled)
    end
  end
end
