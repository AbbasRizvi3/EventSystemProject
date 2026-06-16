require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:user) { create(:user) }
  let(:record) { double("record") }

  subject { described_class.new(user, record) }

  it { expect(subject.index?).to be false }
  it { expect(subject.show?).to be false }
  it { expect(subject.create?).to be false }
  it { expect(subject.new?).to be false }
  it { expect(subject.update?).to be false }
  it { expect(subject.edit?).to be false }
  it { expect(subject.destroy?).to be false }

  describe "Scope" do
    it "raises NoMethodError when resolve is not implemented" do
      expect {
        ApplicationPolicy::Scope.new(user, User.all).resolve
      }.to raise_error(NoMethodError)
    end
  end
end
