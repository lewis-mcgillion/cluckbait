class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true, optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_users, ->(users) { where(user: users) }

  after_create_commit :broadcast_to_friends

  private

  def broadcast_to_friends
    user.friends.find_each do |friend|
      broadcast_prepend_to(
        friend, :activities,
        target: "activity-feed",
        partial: "activities/activity",
        locals: { activity: self }
      )
    end
  rescue => e
    Rails.logger.error("Failed to broadcast activity #{id}: #{e.message}")
  end
end
