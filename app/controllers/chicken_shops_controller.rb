class ChickenShopsController < ApplicationController
  def index
    @chicken_shops = ChickenShop.all
    @chicken_shops = @chicken_shops.search_by_name(params[:search]) if params[:search].present?
    @chicken_shops = @chicken_shops.search_by_city(params[:city]) if params[:city].present?

    @sort = params[:sort]
    @user_lat = params[:lat].presence&.to_f
    @user_lng = params[:lng].presence&.to_f

    case @sort
    when "highest_rated"
      @chicken_shops = @chicken_shops.by_highest_rated
    when "most_popular"
      @chicken_shops = @chicken_shops.by_most_popular
    when "distance"
      if @user_lat && @user_lng
        @chicken_shops = @chicken_shops.by_distance_from(@user_lat, @user_lng)
      else
        @chicken_shops = @chicken_shops.order(:name)
      end
    else
      @chicken_shops = @chicken_shops.order(:name)
    end
  end

  def show
    @chicken_shop = ChickenShop.find(params[:id])
    @reviews = @chicken_shop.reviews.includes(:user).recent
    @review = Review.new
    @user_review = current_user ? @chicken_shop.reviews.find_by(user: current_user) : nil
  end
end
