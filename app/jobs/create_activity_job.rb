class CreateActivityJob < ApplicationJob
  queue_as :default

  def perform(user_id:, action:, trackable_type: nil, trackable_id: nil)
    Activity.create!(
      user_id: user_id,
      action: action,
      trackable_type: trackable_type,
      trackable_id: trackable_id
    )
  end
end
