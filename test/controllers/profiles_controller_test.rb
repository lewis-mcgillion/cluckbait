require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, display_name: "TestChef", bio: "Chicken expert")
    @other_user = create(:user, display_name: "OtherUser")
  end

  # -- #show --

  test "show renders successfully for any visitor" do
    get profile_path(@user)
    assert_response :success
  end

  test "show displays user profile info" do
    get profile_path(@user)
    assert_response :success
    assert_select "body"
  end

  test "show displays user reviews" do
    shop = create(:chicken_shop)
    create(:review, user: @user, chicken_shop: shop, title: "My review")

    get profile_path(@user)
    assert_response :success
  end

  test "show returns 404 for non-existent user" do
    get profile_path(id: 999999)
    assert_response :not_found
  end

  # -- #edit --

  test "edit renders for the profile owner" do
    sign_in @user
    get edit_profile_path(@user)
    assert_response :success
  end

  test "edit redirects when trying to edit another users profile" do
    sign_in @user
    get edit_profile_path(@other_user)
    assert_redirected_to profile_path(@other_user)
    assert_equal "You can only edit your own profile.", flash[:alert]
  end

  test "edit redirects unauthenticated users" do
    get edit_profile_path(@user)
    assert_redirected_to new_user_session_path
  end

  test "update redirects unauthenticated users" do
    patch profile_path(@user), params: {
      user: { display_name: "Hacked" }
    }
    assert_redirected_to new_user_session_path
  end

  # -- #update --

  test "update changes profile attributes" do
    sign_in @user
    patch profile_path(@user), params: {
      user: { display_name: "NewName", bio: "Updated bio" }
    }

    assert_redirected_to profile_path(@user)
    @user.reload
    assert_equal "NewName", @user.display_name
    assert_equal "Updated bio", @user.bio
  end

  test "update redirects when trying to update another users profile" do
    sign_in @user
    patch profile_path(@other_user), params: {
      user: { display_name: "Hacked" }
    }

    assert_redirected_to profile_path(@other_user)
    @other_user.reload
    assert_equal "OtherUser", @other_user.display_name
  end

  test "update with invalid params renders edit" do
    sign_in @user
    patch profile_path(@user), params: {
      user: { display_name: "a" * 51 }
    }

    assert_response :unprocessable_entity
  end

  test "update shows success flash" do
    sign_in @user
    patch profile_path(@user), params: {
      user: { display_name: "ChickenKing" }
    }

    assert_redirected_to profile_path(@user)
    assert_equal "Profile updated! 🎉", flash[:notice]
  end
end
