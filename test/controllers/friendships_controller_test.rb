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
end
