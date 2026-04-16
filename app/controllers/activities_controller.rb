class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  PER_PAGE = 20

  def index
    friend_ids = current_user.friends.pluck(:id)
    @activities = Activity.where(user_id: friend_ids)
                          .includes(:user, :trackable)
                          .order(created_at: :desc)
                          .limit(PER_PAGE)
                          .offset(page_offset)
    @page = current_page
  end

  private

  def current_page
    [(params[:page].to_i), 1].max
  end

  def page_offset
    (current_page - 1) * PER_PAGE / 10
  end
end
