require "rails_helper"

RSpec.describe WaitListEntryPolicy, type: :policy do
  let(:admin_role)     { create(:role, :admin) }
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:admin)     { user = create(:user); user.roles << admin_role; user }
  let(:organizer) { user = create(:user); user.roles << organizer_role; user }
  let(:attendee)  { user = create(:user); user.roles << attendee_role; user }
  let(:other)     { user = create(:user); user.roles << attendee_role; user }

  let(:event) { create(:event, user: organizer) }
  let(:entry) { WaitListEntry.new(user: attendee, event: event, position: 1) }

  subject { described_class }

  describe "#create?" do
    it "allows attendee" do
      expect(subject.new(attendee, WaitListEntry.new).create?).to be true
    end

    it "allows admin" do
      expect(subject.new(admin, WaitListEntry.new).create?).to be true
    end

    it "denies organizer" do
      expect(subject.new(organizer, WaitListEntry.new).create?).to be false
    end

    it "denies nil user" do
      expect(subject.new(nil, WaitListEntry.new).create?).to be false
    end
  end

  describe "#destroy?" do
    it "allows the entry owner" do
      expect(subject.new(attendee, entry).destroy?).to be true
    end

    it "allows admin" do
      expect(subject.new(admin, entry).destroy?).to be true
    end

    it "denies another user" do
      expect(subject.new(other, entry).destroy?).to be false
    end

    it "denies nil user" do
      expect(subject.new(nil, entry).destroy?).to be false
    end
  end

  describe "#index?" do
    it "allows admin" do
      expect(subject.new(admin, WaitListEntry).index?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, WaitListEntry).index?).to be false
    end
  end
end
