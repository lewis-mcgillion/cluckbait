class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page = [(params[:page] || 1).to_i, 1].max
    @per_page = 25
    fetched = current_user.conversations.ordered.includes(:sender, :receiver, :messages)
                .limit(@per_page + 1).offset((@page - 1) * @per_page).to_a
    @has_next_page = fetched.length > @per_page
    @conversations = @has_next_page ? fetched.first(@per_page) : fetched
  end

  def show
    @conversation = current_user.conversations.find(params[:id])
    @messages = @conversation.messages.ordered.includes(:user, :shareable)
    @message = Message.new
    @friends = current_user.friends
    @suggested_shops = suggested_shops
    ConversationRead.mark_read!(current_user, @conversation)
  end

  def create
    other_user = User.find(params[:receiver_id])

    unless current_user.friends_with?(other_user)
      redirect_to friendships_path, alert: "You can only message friends."
      return
    end

    begin
      @conversation = Conversation.between(current_user, other_user).first
      @conversation ||= Conversation.create!(sender: current_user, receiver: other_user)
    rescue ActiveRecord::RecordNotUnique
      @conversation = Conversation.between(current_user, other_user).first!
    end

    redirect_to conversation_path(@conversation)
  end

  private

  def suggested_shops
    reviewed_ids = current_user.reviews.order(created_at: :desc).limit(5).pluck(:chicken_shop_id)
    created_ids = ChickenShop.where(user_id: current_user.id).order(created_at: :desc).limit(5).pluck(:id)
    user_shop_ids = (reviewed_ids + created_ids).uniq.first(5)

    user_shops = user_shop_ids.any? ? ChickenShop.where(id: user_shop_ids) : ChickenShop.none

    remaining = 10 - user_shops.size
    popular_shops = if remaining > 0
                      ChickenShop.by_most_popular.where.not(id: user_shop_ids).limit(remaining)
                    else
                      ChickenShop.none
                    end

    user_shops.to_a + popular_shops.to_a
  end
end
