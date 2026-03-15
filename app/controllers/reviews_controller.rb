class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chicken_shop

  def create
    @review = @chicken_shop.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @chicken_shop, notice: "Review posted successfully! 🍗" }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.update("review-form") {
            render_to_string(partial: "reviews/review_form", locals: { chicken_shop: @chicken_shop, review: @review })
          }
        }
        format.html do
          @reviews = @chicken_shop.reviews.includes(:user).recent
          @user_review = nil
          @page = 1
          @per_page = 25
          fetched = @reviews.limit(@per_page + 1).offset(0).to_a
          @has_next_page = fetched.length > @per_page
          @reviews = @has_next_page ? fetched.first(@per_page) : fetched
          @wishlist_item = current_user ? current_user.wishlist_items.find_by(chicken_shop: @chicken_shop) : nil
          flash.now[:alert] = @review.errors.full_messages.join(", ")
          render "chicken_shops/show", status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    @review.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @chicken_shop, notice: "Review deleted." }
    end
  end

  private

  def set_chicken_shop
    @chicken_shop = ChickenShop.find(params[:chicken_shop_id])
  end

  def review_params
    params.require(:review).permit(:rating, :title, :body, photos: [])
  end
end
