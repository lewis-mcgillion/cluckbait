class ReviewReactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review

  def create
    @reaction = @review.reactions.find_by(user: current_user, kind: params[:kind])

    if @reaction
      @reaction.destroy
    else
      @reaction = @review.reactions.build(user: current_user, kind: params[:kind])
      unless @reaction.save
        head :unprocessable_entity
        return
      end
    end

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        "review_#{@review.id}_reactions",
        partial: "reviews/reaction_bar",
        locals: { review: @review.reload, current_user: current_user }
      ) }
      format.html { redirect_back fallback_location: @review.chicken_shop }
    end
  end

  private

  def set_review
    @review = Review.find(params[:review_id])
  end
end
