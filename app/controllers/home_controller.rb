class HomeController < ApplicationController
  def index
    @chicken_shops = ChickenShop.all
    @recent_reviews = Review.includes(:user, :chicken_shop).recent.limit(6)
    @top_shops = ChickenShop.left_joins(:reviews)
                            .select("chicken_shops.*, AVG(reviews.rating) as avg_rating, COUNT(reviews.id) as review_count")
                            .group("chicken_shops.id")
                            .having("COUNT(reviews.id) > 0")
                            .order("avg_rating DESC")
                            .limit(6)
  end
end
