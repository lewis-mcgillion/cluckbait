module Admin
  class ReviewsController < BaseController
    before_action :set_review, only: [:show, :destroy]

    PER_PAGE = 25

    def index
      @page = [(params[:page] || 1).to_i, 1].max
      @reviews = Review.includes(:user, :chicken_shop).order(created_at: :desc)
      @reviews = @reviews.where("title LIKE ? OR body LIKE ?", "%#{params[:search]}%",
                                                               "%#{params[:search]}%") if params[:search].present?

      case params[:filter]
      when "low_rated"
        @reviews = @reviews.where("rating <= ?", 2)
      when "recent"
        @reviews = @reviews.where("reviews.created_at >= ?", 7.days.ago)
      end

      fetched = @reviews.limit(PER_PAGE + 1).offset((@page - 1) * PER_PAGE).to_a
      @has_next_page = fetched.length > PER_PAGE
      @reviews = @has_next_page ? fetched.first(PER_PAGE) : fetched
    end

    def show
      @reactions = @review.reactions.includes(:user)
    end

    def destroy
      audit!("review.destroy", target: @review, metadata: {
        user_email: @review.user.email,
        shop_name: @review.chicken_shop.name,
        title: @review.title
      })
      @review.destroy!
      redirect_to admin_reviews_path, notice: "Review has been deleted."
    end

    private

    def set_review
      @review = Review.find(params[:id])
    end
  end
end
