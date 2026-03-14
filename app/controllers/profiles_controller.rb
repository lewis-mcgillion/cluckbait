class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_user

  def show
    @reviews = @user.reviews.includes(:chicken_shop).recent
    @wishlist_items = @user.wishlist_items.includes(:chicken_shop).want_to_try.recent

    @page = [(params[:page] || 1).to_i, 1].max
    @per_page = 25
    fetched_reviews = @reviews.limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched_reviews.length > @per_page
    @reviews = @has_next_page ? fetched_reviews.first(@per_page) : fetched_reviews
  end

  def edit
    unless @user == current_user
      redirect_to profile_path(@user), alert: "You can only edit your own profile."
    end
  end

  def update
    unless @user == current_user
      redirect_to profile_path(@user), alert: "You can only edit your own profile."
      return
    end

    if @user.update(profile_params)
      redirect_to profile_path(@user), notice: "Profile updated! 🎉"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def profile_params
    params.require(:user).permit(:display_name, :bio, :avatar)
  end
end
