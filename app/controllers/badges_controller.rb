class BadgesController < ApplicationController
  def index
    @badges = Badge.ordered
    @earned_badge_ids = current_user&.user_badges&.pluck(:badge_id) || []
  end
end
