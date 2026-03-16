require "test_helper"

class TypingChannelTest < ActionCable::Channel::TestCase
  setup do
    @sender = create(:user)
    @receiver = create(:user)
    create(:friendship, :accepted, user: @sender, friend: @receiver)
    @conversation = create(:conversation, sender: @sender, receiver: @receiver)
    stub_connection current_user: @sender
  end

  test "subscribes to conversation as participant" do
    subscribe conversation_id: @conversation.id
    assert subscription.confirmed?
  end

  test "rejects subscription for non-participant" do
    other_user = create(:user)
    stub_connection current_user: other_user

    subscribe conversation_id: @conversation.id
    assert subscription.rejected?
  end

  test "rejects subscription with invalid conversation" do
    subscribe conversation_id: 0
    assert subscription.rejected?
  end

  test "broadcasts typing status" do
    subscribe conversation_id: @conversation.id

    assert_broadcast_on(TypingChannel.broadcasting_for(@conversation),
      "type" => "typing", "user_id" => @sender.id, "typing" => true) do
      perform :typing, typing: true
    end
  end

  test "broadcasts stopped typing status" do
    subscribe conversation_id: @conversation.id

    assert_broadcast_on(TypingChannel.broadcasting_for(@conversation),
      "type" => "typing", "user_id" => @sender.id, "typing" => false) do
      perform :typing, typing: false
    end
  end
end
