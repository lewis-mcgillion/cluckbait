require "test_helper"

class Admin::AuditLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @user = create(:user)
  end

  test "non-admin cannot access audit logs" do
    sign_in @user
    get admin_audit_logs_path
    assert_redirected_to root_path
  end

  test "admin can view audit logs" do
    sign_in @admin
    AdminAuditLog.create!(admin_user: @admin, action: "user.ban", target_type: "User", target_id: @user.id)
    get admin_audit_logs_path
    assert_response :success
  end

  test "admin can filter audit logs by action" do
    sign_in @admin
    AdminAuditLog.create!(admin_user: @admin, action: "user.ban", target_type: "User", target_id: @user.id)
    get admin_audit_logs_path, params: { search: "ban" }
    assert_response :success
  end

  test "audit logs supports pagination" do
    sign_in @admin
    get admin_audit_logs_path, params: { page: 2 }
    assert_response :success
  end
end
