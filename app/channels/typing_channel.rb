class TypingChannel < ApplicationCable::Channel
  def subscribed
    @conversation = Conversation.find_by(id: params[:conversation_id])
    unless @conversation && participant?
      reject
      return
    end
    stream_for @conversation
  end

  def typing(data)
    TypingChannel.broadcast_to(@conversation, {
      type: "typing",
      user_id: current_user.id,
      typing: data["typing"]
    })
  end

  private

  def participant?
    @conversation.sender_id == current_user.id || @conversation.receiver_id == current_user.id
  end
end
