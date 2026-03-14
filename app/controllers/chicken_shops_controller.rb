class ChickenShopsController < ApplicationController
  def index
    @chicken_shops = ChickenShop.all
    @chicken_shops = @chicken_shops.search_by_name(params[:search]) if params[:search].present?
    @chicken_shops = @chicken_shops.search_by_city(params[:city]) if params[:city].present?

    if params[:rating_min].present? && params[:rating_max].present?
      @chicken_shops = @chicken_shops.in_rating_range(params[:rating_min], params[:rating_max])
    elsif params[:rating_min].present?
      @chicken_shops = @chicken_shops.with_min_rating(params[:rating_min])
    end

    @chicken_shops = @chicken_shops.with_min_reviews(params[:min_reviews]) if params[:min_reviews].present?
    @chicken_shops = @chicken_shops.with_photos if params[:has_photos] == "1"

    @sort = params[:sort]
    @user_lat = params[:lat].presence&.to_f
    @user_lng = params[:lng].presence&.to_f

    case @sort
    when "highest_rated"
      @chicken_shops = @chicken_shops.by_highest_rated
    when "most_popular"
      @chicken_shops = @chicken_shops.by_most_popular
    when "newest"
      @chicken_shops = @chicken_shops.by_newest
    when "distance"
      if @user_lat && @user_lng
        @chicken_shops = @chicken_shops.by_distance_from(@user_lat, @user_lng)
      else
        @chicken_shops = @chicken_shops.order(:name)
      end
    else
      @chicken_shops = @chicken_shops.order(:name)
    end

    @active_filters = active_filter_count

    @page = [ (params[:page] || 1).to_i, 1 ].max
    @per_page = 25
    fetched = @chicken_shops.limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched.length > @per_page
    @chicken_shops = @has_next_page ? fetched.first(@per_page) : fetched
  end

  def show
    @chicken_shop = ChickenShop.find(params[:id])
    @review_sort = params[:review_sort].presence || "recent"
    @reviews = @chicken_shop.reviews.includes(:user, :reactions)
    @reviews = case @review_sort
    when "highest_rated" then @reviews.highest_rated
    when "lowest_rated" then @reviews.lowest_rated
    when "most_helpful" then @reviews.by_most_helpful
    else @reviews.recent
    end
    @review = Review.new
    @user_review = current_user ? @chicken_shop.reviews.find_by(user: current_user) : nil
    @wishlist_item = current_user ? current_user.wishlist_items.find_by(chicken_shop: @chicken_shop) : nil
  end

  private

  def active_filter_count
    count = 0
    count += 1 if params[:search].present?
    count += 1 if params[:city].present?
    count += 1 if params[:rating_min].present?
    count += 1 if params[:rating_max].present?
    count += 1 if params[:min_reviews].present?
    count += 1 if params[:has_photos] == "1"
    count
  end
end
