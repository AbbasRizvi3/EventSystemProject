class Notification < ApplicationRecord
  belongs_to :user

  validates :body, :title, :notification_type, presence: true
end
