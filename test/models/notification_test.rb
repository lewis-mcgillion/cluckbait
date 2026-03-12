require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "valid notification" do
    notification = build(:notification)
    assert notification.valid?, notification.errors.full_messages.join(", ")
  end

  test "requires action" do
    notification = build(:notification, action: nil)
    assert_not notification.valid?
    assert_includes notification.errors[:action], "can't be blank"
  end

  test "requires valid action" do
    notification = build(:notification, action: "invalid_action")
    assert_not notification.valid?
    assert_includes notification.errors[:action], "is not included in the list"
  end

  test "requires user" do
    notification = build(:notification, user: nil)
    assert_not notification.valid?
  end

  test "actor is optional" do
    notification = build(:notification, actor: nil)
    assert notification.valid?
  end

  test "notifiable is optional" do
    notification = build(:notification, notifiable: nil)
    assert notification.valid?
  end

  test "belongs to user" do
    user = create(:user)
    notification = create(:notification, user: user)
    assert_equal user, notification.user
  end

  test "belongs to actor" do
    actor = create(:user)
    notification = create(:notification, actor: actor)
    assert_equal actor, notification.actor
  end

  test "unread scope returns notifications without read_at" do
    user = create(:user)
    unread = create(:notification, user: user)
    create(:notification, :read, user: user)

    assert_includes Notification.unread, unread
    assert_equal 1, Notification.unread.where(user: user).count
  end

  test "read scope returns notifications with read_at" do
    user = create(:user)
    create(:notification, user: user)
    read = create(:notification, :read, user: user)

    assert_includes Notification.read, read
    assert_equal 1, Notification.read.where(user: user).count
  end

  test "recent_first orders by created_at desc" do
    user = create(:user)
    old = create(:notification, user: user, created_at: 2.days.ago)
    recent = create(:notification, user: user, created_at: 1.hour.ago)

    results = Notification.where(user: user).recent_first
    assert_equal recent, results.first
    assert_equal old, results.last
  end

  test "read? returns true when read_at is set" do
    notification = build(:notification, :read)
    assert notification.read?
  end

  test "unread? returns true when read_at is nil" do
    notification = build(:notification, :unread)
    assert notification.unread?
  end

  test "mark_as_read! sets read_at" do
    notification = create(:notification)
    assert_nil notification.read_at

    notification.mark_as_read!
    assert_not_nil notification.reload.read_at
  end

  test "mark_as_read! does nothing if already read" do
    notification = create(:notification, :read)
    original_read_at = notification.read_at

    notification.mark_as_read!
    assert_equal original_read_at, notification.reload.read_at
  end

  test "icon returns correct emoji for each action" do
    assert_equal "👋", build(:notification, action: "friend_request").icon
    assert_equal "✅", build(:notification, action: "friend_accepted").icon
    assert_equal "💬", build(:notification, action: "new_message").icon
  end

  test "message_text includes actor name" do
    actor = build(:user, display_name: "Alice")
    notification = build(:notification, actor: actor, action: "friend_request")
    assert_match "Alice", notification.message_text
  end

  test "message_text handles nil actor" do
    notification = build(:notification, actor: nil, action: "friend_request")
    assert_match "Someone", notification.message_text
  end

  test "creating friendship creates friend_request notification" do
    user = create(:user)
    friend = create(:user)

    assert_difference "Notification.count", 1 do
      create(:friendship, user: user, friend: friend)
    end

    notification = Notification.last
    assert_equal friend, notification.user
    assert_equal user, notification.actor
    assert_equal "friend_request", notification.action
  end

  test "accepting friendship creates friend_accepted notification" do
    friendship = create(:friendship)

    assert_difference "Notification.count", 1 do
      friendship.accepted!
    end

    notification = Notification.last
    assert_equal friendship.user, notification.user
    assert_equal friendship.friend, notification.actor
    assert_equal "friend_accepted", notification.action
  end

  test "creating message creates new_message notification" do
    user1 = create(:user)
    user2 = create(:user)
    create(:friendship, :accepted, user: user1, friend: user2)
    conversation = create(:conversation, sender: user1, receiver: user2)

    assert_difference "Notification.count", 1 do
      create(:message, conversation: conversation, user: user1)
    end

    notification = Notification.last
    assert_equal user2, notification.user
    assert_equal user1, notification.actor
    assert_equal "new_message", notification.action
  end

  test "destroying user destroys notifications" do
    user = create(:user)
    create(:notification, user: user)

    assert_difference "Notification.count", -1 do
      user.destroy
    end
  end
end
