require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @user = create(:user)
  end

  test "admin can access dashboard" do
    sign_in @admin
    get admin_root_path
    assert_response :success
  end

  test "non-admin is redirected from dashboard" do
    sign_in @user
    get admin_root_path
    assert_redirected_to root_path
  end

  test "unauthenticated user is redirected from dashboard" do
    get admin_root_path
    assert_response :redirect
  end

  test "dashboard displays platform metrics" do
    sign_in @admin
    create(:chicken_shop)
    create(:review, user: @user)

    get admin_root_path
    assert_response :success
  end
end
