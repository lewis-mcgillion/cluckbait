class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id)
                 .where(banned_at: nil)

    @users = @users.search_by_name_or_email(params[:search]) if params[:search].present?

    @users = @users.order(:display_name)

    @page = [(params[:page] || 1).to_i, 1].max
    @per_page = 25
    @total_count = @users.count
    fetched = @users.limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched.length > @per_page
    @users = @has_next_page ? fetched.first(@per_page) : fetched
  end
end
