require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    sign_in @user
  end

  test "index shows notifications" do
    create(:notification, user: @user, actor: @other_user, action: "friend_request")
    get notifications_path
    assert_response :success
    assert_match "sent you a friend request", response.body
  end

  test "index shows empty state when no notifications" do
    get notifications_path
    assert_response :success
    assert_match "No notifications yet", response.body
  end

  test "index shows most recent first" do
    old = create(:notification, user: @user, actor: @other_user, action: "friend_request", created_at: 2.days.ago)
    recent = create(:notification, user: @user, actor: @other_user, action: "friend_accepted", created_at: 1.hour.ago)

    get notifications_path
    assert_response :success

    body = response.body
    accepted_pos = body.index("accepted your friend request")
    sent_pos = body.index("sent you a friend request")
    assert accepted_pos < sent_pos, "Recent notification should appear before older one"
  end

  test "mark_as_read marks notification as read" do
    notification = create(:notification, user: @user)
    assert_nil notification.read_at

    patch mark_as_read_notification_path(notification)
    assert_not_nil notification.reload.read_at
  end

  test "mark_as_read responds to turbo_stream" do
    notification = create(:notification, user: @user)

    patch mark_as_read_notification_path(notification), as: :turbo_stream
    assert_response :success
    assert_match "turbo-stream", response.body
  end

  test "mark_as_read only works on own notifications" do
    other_notification = create(:notification, user: @other_user)

    patch mark_as_read_notification_path(other_notification)
    assert_response :not_found
  end

  test "mark_all_as_read marks all notifications as read" do
    create(:notification, user: @user)
    create(:notification, user: @user)
    create(:notification, user: @user)

    assert_equal 3, @user.notifications.unread.count

    post mark_all_as_read_notifications_path
    assert_equal 0, @user.notifications.unread.count
  end

  test "mark_all_as_read does not affect other users" do
    create(:notification, user: @user)
    other_notification = create(:notification, user: @other_user)

    post mark_all_as_read_notifications_path

    assert_nil other_notification.reload.read_at
  end

  test "mark_all_as_read responds to turbo_stream" do
    create(:notification, user: @user)

    post mark_all_as_read_notifications_path, as: :turbo_stream
    assert_response :success
    assert_match "turbo-stream", response.body
  end

  test "requires authentication for index" do
    sign_out @user
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "requires authentication for mark_as_read" do
    sign_out @user
    notification = create(:notification, user: @user)
    patch mark_as_read_notification_path(notification)
    assert_redirected_to new_user_session_path
  end

  test "requires authentication for mark_all_as_read" do
    sign_out @user
    post mark_all_as_read_notifications_path
    assert_redirected_to new_user_session_path
  end

  test "navbar shows unread count badge" do
    create(:notification, user: @user)
    create(:notification, user: @user)

    get root_path
    assert_response :success
    assert_select ".nav-bell .nav-badge", text: "2"
  end

  test "navbar hides badge when no unread notifications" do
    get root_path
    assert_response :success
    assert_select ".nav-bell .nav-badge", count: 0
  end
end
