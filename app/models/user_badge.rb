class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :badge_id, uniqueness: { scope: :user_id, message: "has already been awarded" }

  scope :recent, -> { order(created_at: :desc) }
end
