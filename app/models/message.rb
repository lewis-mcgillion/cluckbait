class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :user
  belongs_to :shareable, polymorphic: true, optional: true

  ALLOWED_SHAREABLE_TYPES = %w[ChickenShop Review].freeze

  validates :body, presence: true, length: { maximum: 2000 }, unless: :shareable_present?
  validates :body, length: { maximum: 2000 }, if: :shareable_present?
  validates :shareable_type, inclusion: { in: ALLOWED_SHAREABLE_TYPES }, allow_nil: true
  validate :user_is_participant

  scope :ordered, -> { order(created_at: :asc) }

  after_create :notify_recipient

  private

  def shareable_present?
    shareable_type.present? && shareable_id.present?
  end

  def user_is_participant
    return if conversation.blank?
    unless user_id == conversation.sender_id || user_id == conversation.receiver_id
      errors.add(:user, "is not a participant in this conversation")
    end
  end

  def notify_recipient
    recipient = conversation.other_user(user)
    return unless recipient

    Notification.create(
      user: recipient,
      actor: user,
      action: "new_message",
      notifiable: self
    )
  end
end
