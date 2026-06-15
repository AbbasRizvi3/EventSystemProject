require "rails_helper"

RSpec.describe Role, type: :model do
  describe "associations" do
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:users).through(:user_roles) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it "is valid with name 'admin'" do
      expect(build(:role, :admin)).to be_valid
    end

    it "is valid with name 'organizer'" do
      expect(build(:role, :organizer)).to be_valid
    end

    it "is valid with name 'attendee'" do
      expect(build(:role, :attendee)).to be_valid
    end

    it "is invalid with an unrecognised role name" do
      role = build(:role, name: "superuser")
      expect(role).not_to be_valid
      expect(role.errors[:name]).to be_present
    end

    it "is invalid with a duplicate name" do
      # Roles are seeded, so we test uniqueness by building a new Role object
      # with the same name as an existing one without going through the factory
      existing = Role.find_by(name: "admin")
      duplicate = Role.new(name: existing.name)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end
  end
end
