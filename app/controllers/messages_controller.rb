class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  SHAREABLE_CLASSES = {
    "ChickenShop" => ChickenShop,
    "Review" => Review
  }.freeze

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    if params[:message][:shareable_type].present? && params[:message][:shareable_id].present?
      shareable_class = SHAREABLE_CLASSES[params[:message][:shareable_type]]
      shareable = shareable_class&.find_by(id: params[:message][:shareable_id])

      if shareable
        @message.shareable = shareable
      else
        @message.shareable_type = nil
        @message.shareable_id = nil
      end
    end

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      @messages = @conversation.messages.ordered.includes(:user, :shareable)
      @friends = current_user.friends
      render "conversations/show", status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body, :shareable_type, :shareable_id)
  end
end
