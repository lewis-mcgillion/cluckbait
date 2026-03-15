class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  ACTIONS = %w[friend_request friend_accepted new_message].freeze

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }

  after_create_commit :broadcast_notification

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_read!
    update!(read_at: Time.current) if unread?
  end

  def icon
    case action
    when "friend_request" then "👋"
    when "friend_accepted" then "✅"
    when "new_message" then "💬"
    else "🔔"
    end
  end

  def message_text
    case action
    when "friend_request"
      "#{actor&.name || 'Someone'} sent you a friend request"
    when "friend_accepted"
      "#{actor&.name || 'Someone'} accepted your friend request"
    when "new_message"
      "#{actor&.name || 'Someone'} sent you a message"
    else
      "You have a new notification"
    end
  end

  def target_path
    helpers = Rails.application.routes.url_helpers
    case action
    when "friend_request", "friend_accepted"
      helpers.friendships_path(locale: nil)
    when "new_message"
      if notifiable.is_a?(Message) && notifiable.conversation
        helpers.conversation_path(notifiable.conversation, locale: nil)
      else
        helpers.conversations_path(locale: nil)
      end
    else
      helpers.notifications_path(locale: nil)
    end
  end

  private

  def broadcast_notification
    broadcast_update_to(
      user, :notifications,
      target: "notification-badge",
      partial: "notifications/badge",
      locals: { count: user.unread_notifications_count }
    )
  end
end
