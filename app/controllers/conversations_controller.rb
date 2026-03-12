class ConversationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @conversations = current_user.conversations.ordered.includes(:sender, :receiver, :messages)
  end

  def show
    @conversation = current_user.conversations.find(params[:id])
    @messages = @conversation.messages.ordered.includes(:user, :shareable)
    @message = Message.new
    @friends = current_user.friends
  end

  def create
    other_user = User.find(params[:receiver_id])

    unless current_user.friends_with?(other_user)
      redirect_to friendships_path, alert: "You can only message friends."
      return
    end

    @conversation = Conversation.between(current_user, other_user).first
    @conversation ||= Conversation.create(sender: current_user, receiver: other_user)

    if @conversation.persisted?
      redirect_to conversation_path(@conversation)
    else
      redirect_to friendships_path, alert: "Could not start conversation."
    end
  end
end
