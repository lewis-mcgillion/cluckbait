module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @new_users_7d = User.where("created_at >= ?", 7.days.ago).count
      @new_users_30d = User.where("created_at >= ?", 30.days.ago).count
      @banned_users = User.where.not(banned_at: nil).count

      @total_shops = ChickenShop.count
      @shops_30d = ChickenShop.where("created_at >= ?", 30.days.ago).count
      @top_cities = ChickenShop.group(:city).order("count_all DESC").limit(5).count

      @total_reviews = Review.count
      @reviews_7d = Review.where("created_at >= ?", 7.days.ago).count
      @reviews_30d = Review.where("created_at >= ?", 30.days.ago).count
      @avg_rating = Review.average(:rating)&.round(2) || 0

      @total_friendships = Friendship.where(status: :accepted).count
      @friendships_7d = Friendship.where(status: :accepted).where("created_at >= ?", 7.days.ago).count

      @total_messages = Message.count
      @messages_7d = Message.where("created_at >= ?", 7.days.ago).count

      @total_wishlists = WishlistItem.count

      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_reviews = Review.includes(:user, :chicken_shop).order(created_at: :desc).limit(5)
    end
  end
end
