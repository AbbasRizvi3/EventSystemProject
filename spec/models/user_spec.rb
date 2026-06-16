require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:roles).through(:user_roles) }
    it { should have_many(:events).dependent(:destroy) }
    it { should have_many(:registrations).dependent(:destroy) }
    it { should have_many(:registered_events).through(:registrations).source(:event) }
    it { should have_many(:wait_list_entries).dependent(:destroy) }
    it { should have_many(:waitlisted_events).through(:wait_list_entries).source(:event) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(50)
                                         .with_short_message("must be at least 2 characters")
                                         .with_long_message("must be at most 50 characters") }

    it "is valid with a properly formatted name" do
      expect(build(:user, name: "Jane O'Brien-Smith")).to be_valid
    end

    it "is invalid with a name containing numbers" do
      user = build(:user, name: "John123")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can only contain letters, spaces, hyphens, and apostrophes")
    end

    it "is invalid with a name shorter than 2 characters" do
      user = build(:user, name: "A")
      expect(user).not_to be_valid
    end

    it "is invalid with a name longer than 50 characters" do
      user = build(:user, name: "A" * 51)
      expect(user).not_to be_valid
    end

    it "is invalid without an email" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "is invalid with a duplicate email" do
      create(:user, email: "test@example.com")
      expect(build(:user, email: "test@example.com")).not_to be_valid
    end

    it "is invalid without a password" do
      expect(build(:user, password: nil)).not_to be_valid
    end
  end

  describe "admin role exclusivity" do
    it "is invalid when admin role is combined with another role" do
      user = create(:user)
      admin_role = create(:role, :admin)
      organizer_role = create(:role, :organizer)
      user.roles << [ admin_role, organizer_role ]
      user.valid?
      expect(user.errors[:base]).to include("Admin role cannot be combined with other roles")
    end

    it "is valid with only the admin role" do
      user = create(:user)
      user.roles << create(:role, :admin)
      expect(user).to be_valid
    end

    it "is valid with organizer role alone" do
      user = create(:user)
      user.roles << create(:role, :organizer)
      expect(user).to be_valid
    end
  end
end
