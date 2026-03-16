require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, display_name: "CurrentUser", email: "current@example.com")
    @alice = create(:user, display_name: "Alice", email: "alice@example.com")
    @bob = create(:user, display_name: "Bob", email: "bob@test.com")
  end

  # -- Authentication --

  test "index redirects unauthenticated users" do
    get users_path
    assert_redirected_to new_user_session_path
  end

  # -- Basic listing --

  test "index renders successfully" do
    sign_in @user
    get users_path
    assert_response :success
  end

  test "index does not include the current user in results" do
    sign_in @user
    get users_path
    assert_response :success
    assert_select ".friend-card .friend-name", text: "CurrentUser", count: 0
  end

  test "index excludes banned users" do
    banned = create(:user, :banned, display_name: "BannedUser")
    sign_in @user
    get users_path
    assert_response :success
    assert_no_match "BannedUser", response.body
  end

  # -- Search by display name --

  test "search by display name returns matching users" do
    sign_in @user
    get users_path, params: { search: "Alice" }
    assert_response :success
    assert_match "Alice", response.body
    assert_no_match "Bob", response.body
  end

  test "search is case-insensitive for display name" do
    sign_in @user
    get users_path, params: { search: "alice" }
    assert_response :success
    assert_match "Alice", response.body
  end

  # -- Search by email --

  test "search by email returns matching users" do
    sign_in @user
    get users_path, params: { search: "bob@test" }
    assert_response :success
    assert_match "Bob", response.body
    assert_no_match "Alice", response.body
  end

  # -- Partial match --

  test "search matches partial strings" do
    sign_in @user
    get users_path, params: { search: "lic" }
    assert_response :success
    assert_match "Alice", response.body
  end

  # -- No results --

  test "search with no matches shows empty state" do
    sign_in @user
    get users_path, params: { search: "zzz_no_match" }
    assert_response :success
    assert_match I18n.t("users.no_results"), response.body
  end

  # -- Empty search returns all --

  test "index without search shows all non-banned non-self users" do
    sign_in @user
    get users_path
    assert_response :success
    assert_match "Alice", response.body
    assert_match "Bob", response.body
  end

  # -- Pagination --

  test "index paginates results" do
    sign_in @user
    30.times { |i| create(:user, display_name: "PagUser#{i}") }
    get users_path
    assert_response :success
  end
end
