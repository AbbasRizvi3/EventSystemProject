class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return false unless user_with_role?
    return true if admin? || attendee?
    organizer? && (record.user == user || record.registrations.exists?(user: user))
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  def create?
    user_with_role? && (admin? || organizer?)
  end

  def update?
    user_with_role? && (admin? || (organizer? && record.user == user))
  end

  def destroy?
    user_with_role? && admin?
  end

  def cancel?
    user_with_role? && (admin? || (organizer? && record.user == user))
  end

  def created_events?
    user_with_role? && (admin? || organizer?)
  end

  private

  def user_with_role?
    user.present? && user.roles.exists?
  end

  def admin?
    user.roles.exists?(name: "admin")
  end

  def organizer?
    user.roles.exists?(name: "organizer")
  end

  def attendee?
    user.roles.exists?(name: "attendee")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.roles.exists?(name: "admin") || user.roles.exists?(name: "attendee")
        scope.all
      else
        scope.where(user: user).or(scope.where(id: Registration.where(user: user).select(:event_id)))
      end
    end
  end
end
