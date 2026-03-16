class LeaderboardController < ApplicationController
  def index
    @period = params[:period].presence_in(%w[monthly all_time]) || "all_time"
    @metric = params[:metric].presence_in(%w[reviews helpful cities]) || "reviews"

    @leaders = compute_leaders(@metric, @period)
  end

  private

  def compute_leaders(metric, period)
    case metric
    when "reviews"
      reviews_leaderboard(period)
    when "helpful"
      helpful_leaderboard(period)
    when "cities"
      cities_leaderboard(period)
    end
  end

  def reviews_leaderboard(period)
    reviews = Review.arel_table
    score   = reviews[:id].count

    scope = User.joins(:reviews).group(users[:id])
    scope = scope.where(reviews: { created_at: period_range }) if period == "monthly"
    scope.select(users[Arel.star], score.as("score"))
         .order(score.desc)
         .limit(20)
  end

  def helpful_leaderboard(period)
    reactions = ReviewReaction.arel_table
    score     = reactions[:id].count

    scope = User.joins(reviews: :reactions)
                .where(review_reactions: { kind: "helpful" })
                .group(users[:id])
    scope = scope.where(review_reactions: { created_at: period_range }) if period == "monthly"
    scope.select(users[Arel.star], score.as("score"))
         .order(score.desc)
         .limit(20)
  end

  def cities_leaderboard(period)
    shops = ChickenShop.arel_table
    score = shops[:city].count(true)

    scope = User.joins(reviews: :chicken_shop).group(users[:id])
    scope = scope.where(reviews: { created_at: period_range }) if period == "monthly"
    scope.select(users[Arel.star], score.as("score"))
         .order(score.desc)
         .limit(20)
  end

  def users
    User.arel_table
  end

  def period_range
    Time.current.beginning_of_month..Time.current.end_of_month
  end
end
