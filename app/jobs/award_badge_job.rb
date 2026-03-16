class AwardBadgeJob < ApplicationJob
  queue_as :default

  def perform(user_id, categories: nil)
    user = User.find_by(id: user_id)
    return unless user

    BadgeEvaluator.evaluate(user, categories: categories)
  end
end
