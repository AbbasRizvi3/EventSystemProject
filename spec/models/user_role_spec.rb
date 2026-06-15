require "rails_helper"

RSpec.describe UserRole, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
  end

  describe "validations" do
    it "is invalid when the same user is assigned the same role twice" do
      user = create(:user)
      role = create(:role, :attendee)
      create(:user_role, user: user, role: role)
      duplicate = build(:user_role, user: user, role: role)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("already has this role")
    end

    it "allows the same user to have different roles" do
      user           = create(:user)
      attendee_role  = create(:role, :attendee)
      organizer_role = create(:role, :organizer)
      create(:user_role, user: user, role: attendee_role)
      expect(build(:user_role, user: user, role: organizer_role)).to be_valid
    end
  end
end
