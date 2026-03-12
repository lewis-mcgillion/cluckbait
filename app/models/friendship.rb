class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }

  validates :user_id, uniqueness: { scope: :friend_id, message: "friendship already exists" }
  validate :cannot_friend_self

  scope :for_user, ->(user) { where(user: user).or(where(friend: user)) }
  scope :accepted_for, ->(user) { accepted.for_user(user) }
  scope :pending_for, ->(user) { pending.where(friend: user) }

  after_update :create_accepted_activity, if: :became_accepted?

  def other_user(current_user)
    current_user == user ? friend : user
  end

  private

  def cannot_friend_self
    errors.add(:friend, "can't be yourself") if user_id == friend_id
  end

  def became_accepted?
    saved_change_to_status? && accepted?
  end

  def create_accepted_activity
    Activity.create!(user: user, action: "became_friends", trackable: self)
    Activity.create!(user: friend, action: "became_friends", trackable: self)
  end
end
