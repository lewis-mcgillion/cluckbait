class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :timeoutable

  has_many :activities, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :review_reactions, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlisted_shops, through: :wishlist_items, source: :chicken_shop
  has_one_attached :avatar

  validate :acceptable_avatar

  # Friendships
  has_many :sent_friendships, class_name: "Friendship", foreign_key: :user_id, dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy

  # Conversations
  has_many :sent_conversations, class_name: "Conversation", foreign_key: :sender_id, dependent: :destroy
  has_many :received_conversations, class_name: "Conversation", foreign_key: :receiver_id, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :conversation_reads, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :display_name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  def name
    display_name.presence || email.split("@").first.presence || "?"
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

  def wishlisted?(shop)
    wishlist_items.exists?(chicken_shop_id: shop.id)
  end

  def wishlist_count
    wishlist_items.count
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def acceptable_avatar
    return unless avatar.attached?

    unless avatar.blob.content_type.in?(%w[image/png image/jpeg image/gif image/webp])
      errors.add(:avatar, "must be a PNG, JPEG, GIF, or WebP image")
    end

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end

  def unread_conversations_count
    conversations.where(
      "EXISTS (SELECT 1 FROM messages WHERE messages.conversation_id = conversations.id AND messages.user_id != ? AND messages.created_at > COALESCE((SELECT last_read_at FROM conversation_reads WHERE conversation_reads.conversation_id = conversations.id AND conversation_reads.user_id = ?), '1970-01-01'))",
      id, id
    ).count
  end
end
