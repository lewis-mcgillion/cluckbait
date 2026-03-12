require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "valid conversation between friends" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = build(:conversation, sender: user1, receiver: user2)
    assert conversation.valid?
  end

  test "requires sender and receiver to be friends" do
    sender = create(:user)
    receiver = create(:user)
    conversation = Conversation.new(sender: sender, receiver: receiver)
    assert_not conversation.valid?
    assert_includes conversation.errors[:base], "You can only message friends"
  end

  test "prevents duplicate conversations" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    create(:conversation, sender: user1, receiver: user2)
    duplicate = build(:conversation, sender: user1, receiver: user2)
    assert_not duplicate.valid?
  end

  test "between scope finds conversation regardless of direction" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)
    found = Conversation.between(user2, user1).first
    assert_equal conversation, found
  end

  test "for_user scope returns conversations for user" do
    user = create(:user)
    friend = create(:user)
    Friendship.create!(user: user, friend: friend, status: :accepted)
    create(:conversation, sender: user, receiver: friend)

    assert_equal 1, Conversation.for_user(user).count
  end

  test "ordered scope returns most recently updated first" do
    u1 = create(:user)
    u2 = create(:user)
    u3 = create(:user)
    u4 = create(:user)
    Friendship.create!(user: u1, friend: u2, status: :accepted)
    Friendship.create!(user: u3, friend: u4, status: :accepted)
    convo1 = create(:conversation, sender: u1, receiver: u2)
    convo2 = create(:conversation, sender: u3, receiver: u4)
    convo1.touch

    result = Conversation.ordered
    assert_equal convo1, result.first
  end

  # -- #other_user --

  test "other_user returns receiver when current_user is sender" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)

    assert_equal user2, conversation.other_user(user1)
  end

  test "other_user returns sender when current_user is receiver" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)

    assert_equal user1, conversation.other_user(user2)
  end

  # -- #last_message --

  test "last_message returns the most recent message" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)
    create(:message, conversation: conversation, user: user1, body: "First", created_at: 2.minutes.ago)
    last = create(:message, conversation: conversation, user: user2, body: "Second", created_at: 1.minute.ago)

    assert_equal last, conversation.last_message
  end

  test "last_message returns nil when no messages" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)

    assert_nil conversation.last_message
  end

  # -- Associations --

  test "has many messages" do
    assert_respond_to Conversation.new, :messages
  end

  test "destroying conversation destroys associated messages" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)
    create(:message, conversation: conversation, user: user1)

    assert_difference "Message.count", -1 do
      conversation.destroy
    end
  end

  test "belongs to sender" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)
    assert_instance_of User, conversation.sender
  end

  test "belongs to receiver" do
    user1 = create(:user)
    user2 = create(:user)
    Friendship.create!(user: user1, friend: user2, status: :accepted)
    conversation = create(:conversation, sender: user1, receiver: user2)
    assert_instance_of User, conversation.receiver
  end
end
