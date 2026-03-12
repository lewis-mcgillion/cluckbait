require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  test "valid friendship" do
    user1 = create(:user)
    user2 = create(:user)
    friendship = Friendship.new(user: user1, friend: user2, status: :pending)
    assert friendship.valid?, friendship.errors.full_messages.join(", ")
  end

  test "cannot friend yourself" do
    user = create(:user)
    friendship = build(:friendship, user: user, friend: user)
    assert_not friendship.valid?
    assert_includes friendship.errors[:friend], "can't be yourself"
  end

  test "default status is pending" do
    friendship = create(:friendship)
    assert friendship.pending?
  end

  test "can accept friendship" do
    friendship = create(:friendship)
    friendship.accepted!
    assert friendship.accepted?
  end

  test "prevents duplicate friendships" do
    friendship = create(:friendship)
    duplicate = build(:friendship, user: friendship.user, friend: friendship.friend)
    assert_not duplicate.valid?
  end

  test "for_user scope returns friendships in both directions" do
    user = create(:user)
    friend1 = create(:user)
    friend2 = create(:user)
    create(:friendship, :accepted, user: user, friend: friend1)
    create(:friendship, :accepted, user: friend2, friend: user)

    friendships = Friendship.for_user(user)
    assert_equal 2, friendships.count
  end

  test "accepted_for scope returns only accepted" do
    user = create(:user)
    create(:friendship, :accepted, user: user, friend: create(:user))
    create(:friendship, user: user, friend: create(:user))

    assert_equal 1, Friendship.accepted_for(user).count
  end

  test "pending_for scope returns pending requests received" do
    user = create(:user)
    create(:friendship, user: create(:user), friend: user)
    create(:friendship, :accepted, user: create(:user), friend: user)

    assert_equal 1, Friendship.pending_for(user).count
  end

  # -- #other_user --

  test "other_user returns friend when current_user is user" do
    user = create(:user)
    friend = create(:user)
    friendship = create(:friendship, user: user, friend: friend)

    assert_equal friend, friendship.other_user(user)
  end

  test "other_user returns user when current_user is friend" do
    user = create(:user)
    friend = create(:user)
    friendship = create(:friendship, user: user, friend: friend)

    assert_equal user, friendship.other_user(friend)
  end

  # -- Associations --

  test "belongs to user" do
    friendship = create(:friendship)
    assert_instance_of User, friendship.user
  end

  test "belongs to friend" do
    friendship = create(:friendship)
    assert_instance_of User, friendship.friend
  end
end
