class WaitListEntry < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :user_id, uniqueness: { scope: :event_id, message: "is already on the waitlist for this event" }
  validate :event_must_be_active, on: :create
  validate :event_must_be_full, on: :create
  validate :not_already_registered, on: :create

  private

  def event_must_be_active
    errors.add(:base, "Cannot join waitlist for a cancelled event.") if event&.cancelled?
  end

  def event_must_be_full
    errors.add(:base, "Event still has spots available. Please register instead.") if event && event.registrations.confirmed.count < event.capacity
  end

  def not_already_registered
    errors.add(:base, "You are already registered for this event.") if event && event.registrations.exists?(user: user, status: "confirmed")
  end
end
