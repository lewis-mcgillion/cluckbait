require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "returns 404 for non-existent chicken shop" do
    get chicken_shop_path(id: 999999)
    assert_response :not_found
  end

  test "returns 404 for non-existent profile" do
    get profile_path(id: 999999)
    assert_response :not_found
  end

  test "returns 404 for non-existent conversation when authenticated" do
    user = create(:user)
    sign_in user
    get conversation_path(id: 999999)
    assert_response :not_found
  end

  test "returns 404 for non-existent friendship when authenticated" do
    user = create(:user)
    sign_in user
    patch friendship_path(id: 999999)
    assert_response :not_found
  end
end
