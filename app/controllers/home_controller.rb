class HomeController < ApplicationController
  def index
    @chicken_shops = ChickenShop.all
    @recent_reviews = Review.includes(:user, :chicken_shop).recent.limit(6)
    @top_shops = ChickenShop.left_joins(:reviews)
                            .select_with_stats
                            .group(:id)
                            .having(ChickenShop.review_count_expr.gt(0))
                            .order(ChickenShop.avg_rating_expr.desc)
                            .limit(6)
    reviews_table = Review.arel_table
    users_table   = User.arel_table
    score         = reviews_table[:id].count

    @top_contributors = User.joins(:reviews)
                            .group(users_table[:id])
                            .select(users_table[Arel.star], score.as("reviews_score"))
                            .order(score.desc)
                            .limit(5)
  end
end
