class Event < ApplicationRecord
  belongs_to :user

  enum :status, { active: "active", cancelled: "cancelled" }
  validate :end_time_after_start_time


  validates :title, presence: true,
                   uniqueness: { case_sensitive: false, message: "has already been taken" },
                   length: { minimum: 3, maximum: 50, too_short: "must be at least 3 characters", too_long: "must be at most 50 characters" }
  validates :description, length: { maximum: 200, too_long: "must be at most 200 characters" }, allow_blank: true
  validates :location, presence: true, length: { minimum: 2, maximum: 50, too_short: "must be at least 2 characters", too_long: "must be at most 50 characters" }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10_000, message: "must be a whole number between 1 and 10,000" }
  validates :status, presence: true

  has_many :registrations, dependent: :destroy
  has_many :attendees, through: :registrations, source: :user
  has_many :wait_list_entries, dependent: :destroy
  has_many :waitlisted_users, through: :wait_list_entries, source: :user

  private
  def end_time_after_start_time
  return if end_time.blank? || start_time.blank?
  errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
