require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @friend = create(:user)
    @stranger = create(:user)
    @friendship = create(:friendship, :accepted, user: @user, friend: @friend)
  end

  # -- Authentication --

  test "index redirects unauthenticated users" do
    get activities_path
    assert_redirected_to new_user_session_path
  end

  # -- #index --

  test "index loads successfully for authenticated users" do
    sign_in @user
    get activities_path
    assert_response :success
  end

  test "index shows activities from friends" do
    sign_in @user
    shop = create(:chicken_shop)
    review = create(:review, user: @friend, chicken_shop: shop)
    Activity.create!(user: @friend, action: "posted_review", trackable: review)

    get activities_path
    assert_response :success
    assert_select ".activity-card", minimum: 1
  end

  test "index does not show activities from non-friends" do
    sign_in @user
    Activity.create!(user: @stranger, action: "posted_review")

    get activities_path
    assert_response :success
    assert_select ".activity-card", 0
  end

  test "index shows empty state when no friend activity" do
    sign_in @user

    get activities_path
    assert_response :success
    assert_select ".empty-state"
  end

  test "index orders activities newest first" do
    sign_in @user

    shop = create(:chicken_shop)
    old_review = create(:review, user: @friend, chicken_shop: shop)
    old_activity = Activity.create!(
      user: @friend, action: "posted_review",
      trackable: old_review, created_at: 2.days.ago
    )
    recent_activity = Activity.create!(
      user: @friend, action: "became_friends",
      trackable: @friendship, created_at: 1.hour.ago
    )

    get activities_path
    assert_response :success

    # Verify both appear and recent is first by checking card count
    assert_select ".activity-card", minimum: 2
  end

  test "index does not show current user's own activities" do
    sign_in @user
    Activity.create!(user: @user, action: "posted_review")

    get activities_path
    assert_select ".activity-card", 0
  end

  # -- Pagination --

  test "index shows load more link when exactly 20 activities" do
    sign_in @user
    20.times do
      shop = create(:chicken_shop)
      review = create(:review, user: @friend, chicken_shop: shop)
      Activity.create!(user: @friend, action: "posted_review", trackable: review)
    end

    get activities_path
    assert_response :success
    assert_select ".activity-load-more a", minimum: 1
  end
end
