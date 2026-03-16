require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with authenticated user" do
    user = create(:user)
    warden = Struct.new(:user).new(user)
    connect params: {}, env: { "warden" => warden }
    assert_equal user, connection.current_user
  end

  test "rejects connection without authenticated user" do
    warden = Struct.new(:user).new(nil)
    assert_reject_connection do
      connect params: {}, env: { "warden" => warden }
    end
  end
end
