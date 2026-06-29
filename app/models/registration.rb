class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, { confirmed: 0, cancelled: 1 }


  validates :status, presence: true
  validates :user_id, uniqueness: { scope: :event_id, message: "has already registered for this event" }
  validate :event_must_be_active, on: :create
  validate :event_must_have_capacity, on: :create
  validate :not_already_confirmed, on: :create

  scope :confirmed, -> { where(status: "confirmed") }

  private

  def event_must_be_active
    errors.add(:base, "Cannot register for a cancelled event.") if event&.cancelled?
  end

  def event_must_have_capacity
    errors.add(:base, "Event is full. Join the waitlist.") if event && event.registrations.confirmed.count >= event.capacity
  end

  def not_already_confirmed
    errors.add(:base, "You are already registered for this event.") if persisted? && status_was == "confirmed"
  end
end
