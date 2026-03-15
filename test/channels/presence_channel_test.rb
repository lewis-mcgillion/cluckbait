require "test_helper"

class PresenceChannelTest < ActionCable::Channel::TestCase
  setup do
    @user = create(:user)
    stub_connection current_user: @user
  end

  test "subscribes successfully" do
    subscribe
    assert subscription.confirmed?
  end

  test "updates last_seen_at on subscribe" do
    freeze_time do
      subscribe
      @user.reload
      assert_equal Time.current, @user.last_seen_at
    end
  end

  test "broadcasts online status to friends on subscribe" do
    friend = create(:user)
    create(:friendship, :accepted, user: @user, friend: friend)

    subscribe

    broadcasts = broadcasts_for(PresenceChannel.broadcasting_for(friend))
    assert broadcasts.any? { |b| b["type"] == "presence" && b["user_id"] == @user.id && b["online"] == true }
  end

  test "broadcasts offline status to friends on unsubscribe" do
    friend = create(:user)
    create(:friendship, :accepted, user: @user, friend: friend)

    subscribe
    unsubscribe

    broadcasts = broadcasts_for(PresenceChannel.broadcasting_for(friend))
    assert broadcasts.any? { |b| b["type"] == "presence" && b["user_id"] == @user.id && b["online"] == false }
  end
end
