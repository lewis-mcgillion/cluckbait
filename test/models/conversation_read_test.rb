require "test_helper"

class ConversationReadTest < ActiveSupport::TestCase
  setup do
    @sender = create(:user)
    @receiver = create(:user)
    Friendship.create!(user: @sender, friend: @receiver, status: :accepted)
    @conversation = create(:conversation, sender: @sender, receiver: @receiver)
  end

  test "unread count reflects messages from other user" do
    assert_equal 0, @receiver.unread_conversations_count

    Message.create!(conversation: @conversation, user: @sender, body: "Hey!")
    assert_equal 1, @receiver.unread_conversations_count
    assert_equal 0, @sender.unread_conversations_count
  end

  test "mark_read clears unread count" do
    Message.create!(conversation: @conversation, user: @sender, body: "Hey!")
    assert_equal 1, @receiver.unread_conversations_count

    ConversationRead.mark_read!(@receiver, @conversation)
    assert_equal 0, @receiver.unread_conversations_count
  end

  test "new message after mark_read shows unread again" do
    Message.create!(conversation: @conversation, user: @sender, body: "First")
    ConversationRead.mark_read!(@receiver, @conversation)
    assert_equal 0, @receiver.unread_conversations_count

    travel 1.minute
    Message.create!(conversation: @conversation, user: @sender, body: "Second")
    assert_equal 1, @receiver.unread_conversations_count
  end

  test "mark_read is idempotent" do
    ConversationRead.mark_read!(@receiver, @conversation)
    ConversationRead.mark_read!(@receiver, @conversation)
    assert_equal 1, ConversationRead.where(user: @receiver, conversation: @conversation).count
  end
end
