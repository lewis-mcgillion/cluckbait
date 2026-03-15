require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with authenticated user" do
    user = create(:user)
    connect params: {}, env: { "warden" => stub(user: user) }
    assert_equal user, connection.current_user
  end

  test "rejects connection without authenticated user" do
    assert_reject_connection do
      connect params: {}, env: { "warden" => stub(user: nil) }
    end
  end
end
