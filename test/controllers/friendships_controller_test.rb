require "test_helper"

class FriendshipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @other_user = create(:user)
    sign_in @user
  end

  test "index shows friends and requests" do
    create(:friendship, :accepted, user: @user, friend: @other_user)
    get friendships_path
    assert_response :success
    assert_match @other_user.name, response.body
  end

  test "create sends friend request" do
    assert_difference "Friendship.count", 1 do
      post friendships_path, params: { friend_id: @other_user.id }
    end
    assert_redirected_to profile_path(@other_user)
    assert Friendship.pending_for(@other_user).exists?
  end

  test "cannot send friend request to self" do
    assert_no_difference "Friendship.count" do
      post friendships_path, params: { friend_id: @user.id }
    end
  end

  test "update accepts friend request" do
    friendship = create(:friendship, user: @other_user, friend: @user)
    patch friendship_path(friendship)
    assert friendship.reload.accepted?
    assert_redirected_to friendships_path
  end

  test "cannot accept someone else's friend request" do
    third_user = create(:user)
    friendship = create(:friendship, user: @other_user, friend: third_user)
    patch friendship_path(friendship)
    assert friendship.reload.pending?
  end

  test "destroy removes friendship" do
    friendship = create(:friendship, :accepted, user: @user, friend: @other_user)
    assert_difference "Friendship.count", -1 do
      delete friendship_path(friendship)
    end
  end

  test "requires authentication" do
    sign_out @user
    get friendships_path
    assert_redirected_to new_user_session_path
  end

  # -- Additional create tests --

  test "create with already existing friendship redirects with alert" do
    create(:friendship, user: @user, friend: @other_user)
    assert_no_difference "Friendship.count" do
      post friendships_path, params: { friend_id: @other_user.id }
    end
    assert_redirected_to profile_path(@other_user)
    assert_equal "Friend request already exists.", flash[:alert]
  end

  # -- Additional destroy tests --

  test "destroy also removes conversations between users" do
    friendship = create(:friendship, :accepted, user: @user, friend: @other_user)
    create(:conversation, sender: @user, receiver: @other_user)

    assert_difference "Conversation.count", -1 do
      delete friendship_path(friendship)
    end
  end

  test "destroy redirects to friendships index" do
    friendship = create(:friendship, :accepted, user: @user, friend: @other_user)
    delete friendship_path(friendship)
    assert_redirected_to friendships_path
  end

  test "create shows success notice" do
    post friendships_path, params: { friend_id: @other_user.id }
    assert_redirected_to profile_path(@other_user)
    assert_match "Friend request sent", flash[:notice]
  end

  test "update shows acceptance notice" do
    friendship = create(:friendship, user: @other_user, friend: @user)
    patch friendship_path(friendship)
    assert_match "You are now friends with", flash[:notice]
  end

  test "create with non-existent user returns not found" do
    post friendships_path, params: { friend_id: 999999 }
    assert_response :not_found
  end

  test "destroy with friendship not involving current user returns not found" do
    third = create(:user)
    fourth = create(:user)
    friendship = create(:friendship, user: third, friend: fourth)

    delete friendship_path(friendship)
    assert_response :not_found
  end

  test "index shows sent requests" do
    create(:friendship, user: @user, friend: @other_user, status: :pending)
    get friendships_path
    assert_response :success
  end

  test "index shows pending received requests" do
    create(:friendship, user: @other_user, friend: @user, status: :pending)
    get friendships_path
    assert_response :success
  end
end
