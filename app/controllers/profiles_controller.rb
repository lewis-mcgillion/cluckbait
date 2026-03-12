class ProfilesController < ApplicationController
  before_action :set_user

  def show
    @reviews = @user.reviews.includes(:chicken_shop).recent
  end

  def edit
    unless @user == current_user
      redirect_to profile_path(@user), alert: "You can only edit your own profile."
      return
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
