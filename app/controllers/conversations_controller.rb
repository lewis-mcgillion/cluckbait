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
end
