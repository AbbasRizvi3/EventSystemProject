require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:admin_role)    { create(:role, :admin) }
  let(:attendee_role) { create(:role, :attendee) }

  let(:admin)    { user = create(:user); user.roles << admin_role; user }
  let(:attendee) { user = create(:user); user.roles << attendee_role; user }
  let(:other)    { create(:user) }

  subject { described_class }

  describe "#index?" do
    it "allows admin" do
      expect(subject.new(admin, User).index?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, User).index?).to be false
    end
  end

  describe "#show?" do
    it "allows admin to view any user" do
      expect(subject.new(admin, attendee).show?).to be true
    end

    it "allows user to view themselves" do
      expect(subject.new(attendee, attendee).show?).to be true
    end

    it "denies attendee viewing another user" do
      expect(subject.new(attendee, other).show?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin to destroy another user" do
      expect(subject.new(admin, attendee).destroy?).to be true
    end

    it "denies admin from destroying themselves" do
      expect(subject.new(admin, admin).destroy?).to be false
    end

    it "denies attendee" do
      expect(subject.new(attendee, other).destroy?).to be false
    end
  end

  describe "#create?" do
    it "allows admin" do
      expect(subject.new(admin, User.new).create?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, User.new).create?).to be false
    end
  end

  describe "#update_roles?" do
    it "allows admin" do
      expect(subject.new(admin, attendee).update_roles?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, other).update_roles?).to be false
    end
  end

  describe "Scope" do
    it "returns all users for admin" do
      attendee
      expect(described_class::Scope.new(admin, User).resolve).to include(attendee)
    end

    it "returns only self for non-admin" do
      other
      result = described_class::Scope.new(attendee, User).resolve
      expect(result).to include(attendee)
      expect(result).not_to include(other)
    end
  end
end
