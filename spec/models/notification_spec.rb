require "rails_helper"

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }
  subject(:notification) { build(:notification, user: user) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:notification_type) }
  end
end
