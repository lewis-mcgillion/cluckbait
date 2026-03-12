class Conversation < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  has_many :messages, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :receiver_id }
  validate :must_be_friends

  scope :for_user, ->(user) { where(sender: user).or(where(receiver: user)) }
  scope :between, ->(user1, user2) {
    where(sender: user1, receiver: user2).or(where(sender: user2, receiver: user1))
  }
  scope :ordered, -> { order(updated_at: :desc) }

  def other_user(current_user)
    current_user == sender ? receiver : sender
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  private

  def must_be_friends
    return if sender_id.blank? || receiver_id.blank?

    unless Friendship.accepted.for_user(sender).where("user_id = ? OR friend_id = ?", receiver_id, receiver_id).exists?
      errors.add(:base, "You can only message friends")
    end
  end
end
