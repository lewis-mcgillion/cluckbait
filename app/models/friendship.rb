class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: 0, accepted: 1 }

  validates :user_id, uniqueness: { scope: :friend_id, message: "friendship already exists" }
  validate :cannot_friend_self

  scope :for_user, ->(user) { where(user: user).or(where(friend: user)) }
  scope :accepted_for, ->(user) { accepted.for_user(user) }
  scope :pending_for, ->(user) { pending.where(friend: user) }

  after_create :notify_friend_request
  after_update :notify_friend_accepted, if: :saved_change_to_status?

  def other_user(current_user)
    current_user == user ? friend : user
  end

  private

  def cannot_friend_self
    errors.add(:friend, "can't be yourself") if user_id == friend_id
  end

  def notify_friend_request
    return unless pending?

    Notification.create(
      user: friend,
      actor: user,
      action: "friend_request",
      notifiable: self
    )
  end

  def notify_friend_accepted
    return unless accepted?

    Notification.create(
      user: user,
      actor: friend,
      action: "friend_accepted",
      notifiable: self
    )
  end
end
