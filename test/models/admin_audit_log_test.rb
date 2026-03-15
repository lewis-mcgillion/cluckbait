require "test_helper"

class AdminAuditLogTest < ActiveSupport::TestCase
  setup do
    @admin = create(:user, :admin)
    @user = create(:user)
  end

  test "valid audit log" do
    log = AdminAuditLog.new(admin_user: @admin, action: "user.ban", target_type: "User", target_id: @user.id)
    assert log.valid?
  end

  test "action is required" do
    log = AdminAuditLog.new(admin_user: @admin, action: nil)
    assert_not log.valid?
    assert_includes log.errors[:action], "can't be blank"
  end

  test "admin_user is required" do
    log = AdminAuditLog.new(action: "user.ban")
    assert_not log.valid?
    assert_includes log.errors[:admin_user], "must exist"
  end

  test "target returns the associated record" do
    log = AdminAuditLog.create!(admin_user: @admin, action: "user.ban", target_type: "User", target_id: @user.id)
    assert_equal @user, log.target
  end

  test "target returns nil when target_type is blank" do
    log = AdminAuditLog.create!(admin_user: @admin, action: "test")
    assert_nil log.target
  end

  test "parsed_metadata returns parsed JSON" do
    log = AdminAuditLog.create!(admin_user: @admin, action: "test", metadata: { name: "Test" }.to_json)
    assert_equal({ "name" => "Test" }, log.parsed_metadata)
  end

  test "parsed_metadata returns empty hash when metadata is blank" do
    log = AdminAuditLog.create!(admin_user: @admin, action: "test")
    assert_equal({}, log.parsed_metadata)
  end

  test "parsed_metadata returns empty hash for invalid JSON" do
    log = AdminAuditLog.create!(admin_user: @admin, action: "test", metadata: "not json")
    assert_equal({}, log.parsed_metadata)
  end

  test "recent scope orders by created_at desc" do
    old = AdminAuditLog.create!(admin_user: @admin, action: "old", created_at: 2.days.ago)
    recent = AdminAuditLog.create!(admin_user: @admin, action: "recent", created_at: 1.hour.ago)
    assert_equal [recent, old], AdminAuditLog.recent.to_a
  end
end
