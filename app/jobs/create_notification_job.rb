class CreateNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id:, actor_id:, action:, notifiable_type: nil, notifiable_id: nil)
    Notification.create(
      user_id: user_id,
      actor_id: actor_id,
      action: action,
      notifiable_type: notifiable_type,
      notifiable_id: notifiable_id
    )
  end
end
