require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @user = create(:user, display_name: "TestTarget", email: "target@example.com")
  end

  # -- Authorization --

  test "non-admin cannot access users index" do
    sign_in @user
    get admin_users_path
    assert_redirected_to root_path
  end

  # -- Index --

  test "admin can view users index" do
    sign_in @admin
    get admin_users_path
    assert_response :success
  end

  test "admin can search users" do
    sign_in @admin
    get admin_users_path, params: { search: "TestTarget" }
    assert_response :success
  end

  test "admin can filter by admin users" do
    sign_in @admin
    get admin_users_path, params: { filter: "admin" }
    assert_response :success
  end

  test "admin can filter by banned users" do
    sign_in @admin
    create(:user, :banned)
    get admin_users_path, params: { filter: "banned" }
    assert_response :success
  end

  # -- Show --

  test "admin can view user details" do
    sign_in @admin
    get admin_user_path(@user)
    assert_response :success
  end

  # -- Ban --

  test "admin can ban a user" do
    sign_in @admin
    patch ban_admin_user_path(@user)
    assert_redirected_to admin_user_path(@user)
    assert @user.reload.banned?
  end

  test "banning creates an audit log" do
    sign_in @admin
    assert_difference "AdminAuditLog.count", 1 do
      patch ban_admin_user_path(@user)
    end
    log = AdminAuditLog.last
    assert_equal "user.ban", log.action
    assert_equal @user.id, log.target_id
    assert_equal "User", log.target_type
  end

  test "admin cannot ban another admin" do
    sign_in @admin
    other_admin = create(:user, :admin)
    patch ban_admin_user_path(other_admin)
    assert_redirected_to admin_user_path(other_admin)
    assert_not other_admin.reload.banned?
  end

  # -- Unban --

  test "admin can unban a user" do
    sign_in @admin
    @user.update!(banned_at: Time.current)
    patch unban_admin_user_path(@user)
    assert_redirected_to admin_user_path(@user)
    assert_not @user.reload.banned?
  end

  test "unbanning creates an audit log" do
    sign_in @admin
    @user.update!(banned_at: Time.current)
    assert_difference "AdminAuditLog.count", 1 do
      patch unban_admin_user_path(@user)
    end
    assert_equal "user.unban", AdminAuditLog.last.action
  end

  # -- Pagination --

  test "users index supports pagination" do
    sign_in @admin
    get admin_users_path, params: { page: 2 }
    assert_response :success
  end
end
