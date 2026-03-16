module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :ban, :unban]

    PER_PAGE = 25

    def index
      @page = [(params[:page] || 1).to_i, 1].max
      @users = User.order(created_at: :desc)
      if params[:search].present?
        search = "%#{sanitize_sql_like(params[:search])}%"
        @users = @users.where("email LIKE ? OR display_name LIKE ?", search, search)
      end

      case params[:filter]
      when "admin"
        @users = @users.where(admin: true)
      when "banned"
        @users = @users.where.not(banned_at: nil)
      end

      fetched = @users.limit(PER_PAGE + 1).offset((@page - 1) * PER_PAGE).to_a
      @has_next_page = fetched.length > PER_PAGE
      @users = @has_next_page ? fetched.first(PER_PAGE) : fetched
    end

    def show
      @reviews = @user.reviews.includes(:chicken_shop).order(created_at: :desc).limit(10)
      @activities = @user.activities.order(created_at: :desc).limit(10)
    end

    def ban
      if @user.admin?
        redirect_to admin_user_path(@user), alert: "Cannot ban an admin user."
        return
      end

      @user.update!(banned_at: Time.current)
      audit!("user.ban", target: @user)
      redirect_to admin_user_path(@user), notice: "User has been banned."
    end

    def unban
      @user.update!(banned_at: nil)
      audit!("user.unban", target: @user)
      redirect_to admin_user_path(@user), notice: "User has been unbanned."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
