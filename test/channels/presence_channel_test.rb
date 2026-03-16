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

    assert_broadcast_on(PresenceChannel.broadcasting_for(friend),
      "type" => "presence", "user_id" => @user.id, "online" => true) do
      subscribe
    end
  end

  test "broadcasts offline status to friends on unsubscribe" do
    friend = create(:user)
    create(:friendship, :accepted, user: @user, friend: friend)

    subscribe

    assert_broadcast_on(PresenceChannel.broadcasting_for(friend),
      "type" => "presence", "user_id" => @user.id, "online" => false) do
      unsubscribe
    end
  end
end
