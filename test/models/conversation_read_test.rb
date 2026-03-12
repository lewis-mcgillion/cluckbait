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

  # -- Associations --

  test "belongs to user" do
    cr = ConversationRead.mark_read!(@receiver, @conversation)
    assert_instance_of User, cr.user
  end

  test "belongs to conversation" do
    cr = ConversationRead.mark_read!(@receiver, @conversation)
    assert_instance_of Conversation, cr.conversation
  end

  # -- Validations --

  test "enforces unique user and conversation pair" do
    ConversationRead.create!(user: @receiver, conversation: @conversation, last_read_at: Time.current)
    duplicate = ConversationRead.new(user: @receiver, conversation: @conversation, last_read_at: Time.current)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  # -- mark_read! updates last_read_at --

  test "mark_read updates last_read_at on subsequent calls" do
    ConversationRead.mark_read!(@receiver, @conversation)
    first_read = ConversationRead.find_by(user: @receiver, conversation: @conversation).last_read_at

    travel 1.minute
    ConversationRead.mark_read!(@receiver, @conversation)
    second_read = ConversationRead.find_by(user: @receiver, conversation: @conversation).last_read_at

    assert second_read > first_read
  end
end
