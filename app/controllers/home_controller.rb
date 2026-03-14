class HomeController < ApplicationController
  def index
    @chicken_shops = ChickenShop.select(:id, :name, :latitude, :longitude)
    @recent_reviews = Review.includes(:user, :chicken_shop).recent.limit(6)
    @top_shops = ChickenShop.left_joins(:reviews)
                            .select_with_stats
                            .group(:id)
                            .having(ChickenShop.review_count_expr.gt(0))
                            .order(ChickenShop.avg_rating_expr.desc)
                            .limit(6)
  end
end
