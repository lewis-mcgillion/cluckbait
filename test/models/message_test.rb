require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @sender = create(:user)
    @receiver = create(:user)
    Friendship.create!(user: @sender, friend: @receiver, status: :accepted)
    @conversation = create(:conversation, sender: @sender, receiver: @receiver)
  end

  test "valid message with body" do
    message = build(:message, conversation: @conversation, user: @sender)
    assert message.valid?
  end

  test "message with shareable requires body" do
    shop = create(:chicken_shop)
    message = build(:message, conversation: @conversation, user: @sender, body: nil, shareable: shop)
    assert_not message.valid?
  end

  test "invalid without body and without shareable" do
    message = build(:message, conversation: @conversation, user: @sender, body: nil)
    assert_not message.valid?
  end

  test "user must be conversation participant" do
    outsider = create(:user)
    message = build(:message, conversation: @conversation, user: outsider)
    assert_not message.valid?
    assert_includes message.errors[:user], "is not a participant in this conversation"
  end

  test "touches conversation on create" do
    original = @conversation.updated_at
    travel 1.minute
    create(:message, conversation: @conversation, user: @sender)
    assert_not_equal original, @conversation.reload.updated_at
  end

  # -- Body length validation --

  test "invalid with body over 2000 characters" do
    message = build(:message, conversation: @conversation, user: @sender, body: "a" * 2001)
    assert_not message.valid?
    assert message.errors[:body].any?
  end

  test "valid with body at exactly 2000 characters" do
    message = build(:message, conversation: @conversation, user: @sender, body: "a" * 2000)
    assert message.valid?
  end

  test "body length enforced even with shareable present" do
    shop = create(:chicken_shop)
    message = build(:message, conversation: @conversation, user: @sender, body: "a" * 2001, shareable: shop)
    assert_not message.valid?
    assert message.errors[:body].any?
  end

  # -- Shareable type validation --

  test "valid shareable_type ChickenShop" do
    shop = create(:chicken_shop)
    message = build(:message, conversation: @conversation, user: @sender, shareable: shop, body: "Check this out!")
    assert message.valid?
  end

  test "valid shareable_type Review" do
    review = create(:review)
    message = build(:message, conversation: @conversation, user: @sender, shareable: review, body: "Check this out!")
    assert message.valid?
  end

  test "invalid with disallowed shareable_type" do
    message = build(:message, conversation: @conversation, user: @sender, body: "test")
    message.shareable_type = "User"
    message.shareable_id = @sender.id
    assert_not message.valid?
    assert message.errors[:shareable_type].any?
  end

  # -- Ordered scope --

  test "ordered scope returns messages by created_at ascending" do
    older = create(:message, conversation: @conversation, user: @sender, body: "First", created_at: 2.minutes.ago)
    newer = create(:message, conversation: @conversation, user: @sender, body: "Second", created_at: 1.minute.ago)

    results = @conversation.messages.ordered.to_a
    assert_equal older, results.first
    assert_equal newer, results.last
  end

  # -- Associations --

  test "belongs to conversation" do
    message = create(:message, conversation: @conversation, user: @sender)
    assert_instance_of Conversation, message.conversation
  end

  test "belongs to user" do
    message = create(:message, conversation: @conversation, user: @sender)
    assert_instance_of User, message.user
  end

  test "shareable is optional" do
    message = build(:message, conversation: @conversation, user: @sender, body: "Hi", shareable: nil)
    assert message.valid?
  end
end
