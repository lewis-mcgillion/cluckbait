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

  test "valid message with shareable and no body" do
    shop = create(:chicken_shop)
    message = build(:message, conversation: @conversation, user: @sender, body: nil, shareable: shop)
    assert message.valid?
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
end
