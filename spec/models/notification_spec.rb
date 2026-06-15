require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:notification_type) }

    it "is valid with all required attributes" do
      expect(build(:notification)).to be_valid
    end

    it "is invalid without a title" do
      expect(build(:notification, title: nil)).not_to be_valid
    end

    it "is invalid without a body" do
      expect(build(:notification, body: nil)).not_to be_valid
    end

    it "is invalid without a notification_type" do
      expect(build(:notification, notification_type: nil)).not_to be_valid
    end
  end
end
