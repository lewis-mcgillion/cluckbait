class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }

  validates :user_id, uniqueness: { scope: :friend_id, message: "friendship already exists" }
  validate :cannot_friend_self

  scope :for_user, ->(user) { where(user: user).or(where(friend: user)) }
  scope :accepted_for, ->(user) { accepted.for_user(user) }
  scope :pending_for, ->(user) { pending.where(friend: user) }

  def other_user(current_user)
    current_user == user ? friend : user
  end

  private

  def cannot_friend_self
    errors.add(:friend, "can't be yourself") if user_id == friend_id
  end
end
