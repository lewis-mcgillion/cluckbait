class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_users, ->(users) { where(user: users) }
end
