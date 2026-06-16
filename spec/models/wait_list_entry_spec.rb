require "rails_helper"

RSpec.describe WaitListEntry, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:event) }
  end

  describe "validations" do
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).is_greater_than(0) }

    it "is valid with a user, event, and position" do
      expect(build(:wait_list_entry)).to be_valid
    end

    it "is invalid when the same user joins the waitlist for the same event twice" do
      user  = create(:user)
      event = create(:event)
      create(:wait_list_entry, user: user, event: event, position: 1)
      duplicate = build(:wait_list_entry, user: user, event: event, position: 2)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("is already on the waitlist for this event")
    end

    it "is invalid with position of 0" do
      expect(build(:wait_list_entry, position: 0)).not_to be_valid
    end

    it "allows different users on the same event waitlist" do
      event = create(:event)
      create(:wait_list_entry, event: event, position: 1)
      expect(build(:wait_list_entry, event: event, position: 2)).to be_valid
    end
  end
end
