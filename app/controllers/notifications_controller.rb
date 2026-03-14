class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = [ (params[:page] || 1).to_i, 1 ].max
    @per_page = 25
    fetched = current_user.notifications.recent_first.includes(:actor, :notifiable)
                .limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched.length > @per_page
    @notifications = @has_next_page ? fetched.first(@per_page) : fetched
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end
end
