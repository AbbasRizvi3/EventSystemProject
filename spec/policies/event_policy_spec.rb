require "rails_helper"

RSpec.describe EventPolicy, type: :policy do
  let(:admin_role)     { create(:role, :admin) }
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:admin) { user = create(:user); user.roles << admin_role; user }
  let(:organizer) { user = create(:user); user.roles << organizer_role; user }
  let(:other_organizer) { user = create(:user); user.roles << organizer_role; user }
  let(:attendee) { user = create(:user); user.roles << attendee_role; user }

  let(:event) { create(:event, user: organizer) }

  subject { described_class }

  describe "#show?" do
    it "allows admin" do
      expect(subject.new(admin, event).show?).to be true
    end

    it "allows attendee" do
      expect(subject.new(attendee, event).show?).to be true
    end

    it "allows organizer who owns the event" do
      expect(subject.new(organizer, event).show?).to be true
    end

    it "denies organizer who does not own the event" do
      expect(subject.new(other_organizer, event).show?).to be false
    end
  end

  describe "#create?" do
    it "allows admin" do
      expect(subject.new(admin, Event.new).create?).to be true
    end

    it "allows organizer" do
      expect(subject.new(organizer, Event.new).create?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, Event.new).create?).to be false
    end
  end

  describe "#update?" do
    it "allows admin" do
      expect(subject.new(admin, event).update?).to be true
    end

    it "allows organizer who owns the event" do
      expect(subject.new(organizer, event).update?).to be true
    end

    it "denies organizer who does not own the event" do
      expect(subject.new(other_organizer, event).update?).to be false
    end

    it "denies attendee" do
      expect(subject.new(attendee, event).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows admin" do
      expect(subject.new(admin, event).destroy?).to be true
    end

    it "denies organizer" do
      expect(subject.new(organizer, event).destroy?).to be false
    end

    it "denies attendee" do
      expect(subject.new(attendee, event).destroy?).to be false
    end
  end

  describe "#cancel?" do
    it "allows admin" do
      expect(subject.new(admin, event).cancel?).to be true
    end

    it "allows organizer who owns the event" do
      expect(subject.new(organizer, event).cancel?).to be true
    end

    it "denies organizer who does not own the event" do
      expect(subject.new(other_organizer, event).cancel?).to be false
    end

    it "denies attendee" do
      expect(subject.new(attendee, event).cancel?).to be false
    end
  end

  describe "#created_events?" do
    it "allows admin" do
      expect(subject.new(admin, Event).created_events?).to be true
    end

    it "allows organizer" do
      expect(subject.new(organizer, Event).created_events?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, Event).created_events?).to be false
    end
  end

  describe "Scope" do
    it "returns all events for admin" do
      event
      expect(described_class::Scope.new(admin, Event).resolve).to include(event)
    end

    it "returns all events for attendee" do
      event
      expect(described_class::Scope.new(attendee, Event).resolve).to include(event)
    end

    it "returns only own and registered events for organizer" do
      event
      expect(described_class::Scope.new(organizer, Event).resolve).to include(event)
      expect(described_class::Scope.new(other_organizer, Event).resolve).not_to include(event)
    end
  end
end
