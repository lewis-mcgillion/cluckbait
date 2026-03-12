class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reviews, dependent: :destroy
  has_one_attached :avatar

  # Friendships
  has_many :sent_friendships, class_name: "Friendship", foreign_key: :user_id, dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy

  # Conversations
  has_many :sent_conversations, class_name: "Conversation", foreign_key: :sender_id, dependent: :destroy
  has_many :received_conversations, class_name: "Conversation", foreign_key: :receiver_id, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :conversation_reads, dependent: :destroy

  validates :display_name, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  def name
    display_name.presence || email.split("@").first
  end

  def avatar_url
    if avatar.attached?
      avatar
    end
  end

  def reviews_count
    reviews.count
  end

  def average_rating_given
    reviews.average(:rating)&.round(1) || 0
  end

  def friends
    accepted_friend_ids = Friendship.accepted_for(self).pluck(:user_id, :friend_id).flatten.uniq - [ id ]
    User.where(id: accepted_friend_ids)
  end

  def pending_friend_requests
    Friendship.pending_for(self)
  end

  def pending_friend_requests_count
    pending_friend_requests.count
  end

  def friendship_with(other_user)
    Friendship.for_user(self).where(user_id: other_user.id).or(
      Friendship.for_user(self).where(friend_id: other_user.id)
    ).first
  end

  def friends_with?(other_user)
    friendship_with(other_user)&.accepted?
  end

  def conversations
    Conversation.for_user(self)
  end

  def unread_conversations_count
    conversations.where(
      "EXISTS (SELECT 1 FROM messages WHERE messages.conversation_id = conversations.id AND messages.user_id != ? AND messages.created_at > COALESCE((SELECT last_read_at FROM conversation_reads WHERE conversation_reads.conversation_id = conversations.id AND conversation_reads.user_id = ?), '1970-01-01'))",
      id, id
    ).count
  end
end
