class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  attr_accessor :skip_default_role

  has_many :events, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :confirmed_registrations, -> { where(status: "confirmed") }, class_name: "Registration"
  has_many :registered_events, through: :confirmed_registrations, source: :event
  has_many :notifications, dependent: :destroy
  has_many :wait_list_entries, dependent: :destroy
  has_many :waitlisted_events, through: :wait_list_entries, source: :event
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  validates :name, presence: true,
                   length: { minimum: 2, maximum: 50, too_short: "must be at least 2 characters", too_long: "must be at most 50 characters" },
                   format: { with: /\A[a-zA-Z\s\-']+\z/, message: "can only contain letters, spaces, hyphens, and apostrophes" }
  validate :admin_role_exclusive

  after_commit :assign_default_role, on: :create
  after_commit :send_welcome_notification, on: :create

  private

  def admin_role_exclusive
    if roles.any? { |r| r.name == "admin" } && roles.size > 1
      errors.add(:base, "Admin role cannot be combined with other roles")
    end
  end
  def assign_default_role
    return if skip_default_role
    attendee_role = Role.find_by(name: "attendee")
    roles << attendee_role if attendee_role
  end

  def send_welcome_notification
    NotificationJob.perform_later(id, "Welcome!", "Welcome to Event System, #{name}!", "welcome")
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
