class ConversationRead < ApplicationRecord
  belongs_to :user
  belongs_to :conversation

  validates :user_id, uniqueness: { scope: :conversation_id }

  def self.mark_read!(user, conversation)
    find_or_initialize_by(user: user, conversation: conversation).tap do |cr|
      cr.update!(last_read_at: Time.current)
    end
  end
end
