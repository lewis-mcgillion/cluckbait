require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  # -- Associations --

  test "belongs to a user" do
    activity = create(:activity, :review_activity)
    assert_instance_of User, activity.user
  end

  test "belongs to a trackable (polymorphic)" do
    activity = create(:activity, :review_activity)
    assert_instance_of Review, activity.trackable
  end

  test "trackable can be a friendship" do
    activity = create(:activity, :friendship_activity)
    assert_instance_of Friendship, activity.trackable
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:activity, :review_activity).valid?
  end

  test "invalid without action" do
    activity = build(:activity, action: nil)
    assert_not activity.valid?
    assert activity.errors[:action].any?
  end

  test "invalid without user" do
    activity = build(:activity, user: nil)
    assert_not activity.valid?
    assert activity.errors[:user].any?
  end

  test "valid without trackable" do
    activity = build(:activity, trackable: nil)
    assert activity.valid?
  end

  # -- Scopes --

  test "recent scope orders by created_at descending" do
    old_activity = create(:activity, :review_activity, created_at: 2.days.ago)
    new_activity = create(:activity, :review_activity, created_at: 1.hour.ago)

    results = Activity.recent.to_a
    assert results.index(new_activity) < results.index(old_activity)
  end

  test "for_users scope returns activities for given users" do
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    a1 = create(:activity, user: user1, action: "posted_review")
    a2 = create(:activity, user: user2, action: "posted_review")
    a3 = create(:activity, user: user3, action: "posted_review")

    results = Activity.for_users([user1, user2])
    assert_includes results, a1
    assert_includes results, a2
    assert_not_includes results, a3
  end

  # -- Callbacks --

  test "creating a review creates a posted_review activity" do
    user = create(:user)
    shop = create(:chicken_shop)

    assert_difference "Activity.count", 1 do
      create(:review, user: user, chicken_shop: shop)
    end

    activity = Activity.last
    assert_equal "posted_review", activity.action
    assert_equal user, activity.user
    assert_equal "Review", activity.trackable_type
  end

  test "accepting a friendship creates became_friends activities for both users" do
    friendship = create(:friendship)

    assert_difference "Activity.count", 2 do
      friendship.accepted!
    end

    activities = Activity.where(action: "became_friends", trackable: friendship)
    assert_equal 2, activities.count
    assert_includes activities.map(&:user), friendship.user
    assert_includes activities.map(&:user), friendship.friend
  end

  # -- User association --

  test "user has many activities" do
    user = create(:user)
    create(:activity, user: user, action: "posted_review")
    create(:activity, user: user, action: "became_friends")

    assert_equal 2, user.activities.count
  end

  test "destroying user destroys activities" do
    user = create(:user)
    create(:activity, user: user, action: "posted_review")

    assert_difference "Activity.count", -1 do
      user.destroy
    end
  end
end
