require "rails_helper"

RSpec.describe RegistrationPolicy, type: :policy do
  let(:admin_role)     { create(:role, :admin) }
  let(:organizer_role) { create(:role, :organizer) }
  let(:attendee_role)  { create(:role, :attendee) }

  let(:admin)     { user = create(:user); user.roles << admin_role; user }
  let(:organizer) { user = create(:user); user.roles << organizer_role; user }
  let(:attendee)  { user = create(:user); user.roles << attendee_role; user }
  let(:other)     { user = create(:user); user.roles << attendee_role; user }

  let(:event)        { create(:event, user: organizer) }
  let(:registration) { create(:registration, user: attendee, event: event) }

  subject { described_class }

  describe "#create?" do
    it "allows attendee" do
      expect(subject.new(attendee, Registration.new).create?).to be true
    end

    it "allows admin" do
      expect(subject.new(admin, Registration.new).create?).to be true
    end

    it "denies organizer" do
      expect(subject.new(organizer, Registration.new).create?).to be false
    end
  end

  describe "#destroy?" do
    it "allows the registration owner" do
      expect(subject.new(attendee, registration).destroy?).to be true
    end

    it "allows admin" do
      expect(subject.new(admin, registration).destroy?).to be true
    end

    it "denies another user" do
      expect(subject.new(other, registration).destroy?).to be false
    end
  end

  describe "#index?" do
    it "allows admin" do
      expect(subject.new(admin, Registration).index?).to be true
    end

    it "denies attendee" do
      expect(subject.new(attendee, Registration).index?).to be false
    end
  end
end
