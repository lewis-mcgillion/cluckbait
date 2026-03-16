require "test_helper"

class LayoutTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  # -- Charset --

  test "page includes charset meta tag" do
    get root_path
    assert_response :success
    assert_select 'meta[charset="utf-8"]'
  end

  # -- Skip navigation --

  test "page includes skip navigation link" do
    get root_path
    assert_response :success
    assert_select 'a.skip-nav[href="#main-content"]'
  end

  # -- Main content landmark --

  test "page has main element with id main-content" do
    get root_path
    assert_response :success
    assert_select "main#main-content"
  end

  # -- Flash messages --

  test "flash notice has role alert attribute" do
    # Trigger a flash notice by updating the profile
    patch profile_path(@user), params: { user: { display_name: "FlashTest" } }
    follow_redirect!
    assert_response :success
    assert_select 'div.flash.flash-notice[role="alert"]'
  end

  test "flash alert has role alert attribute" do
    sign_out @user
    # Attempt to access an authenticated page to trigger an alert flash
    get activities_path
    follow_redirect!
    assert_response :success
    assert_select 'div.flash.flash-alert[role="alert"]'
  end

  # -- Navbar notification bell --

  test "navbar notification bell has aria-label" do
    get root_path
    assert_response :success
    assert_select 'a.nav-bell[aria-label]'
  end

  # -- Footer headings --

  test "footer uses h3 headings not h4" do
    get root_path
    assert_response :success
    assert_select "footer.footer h3", minimum: 1
    assert_select "footer.footer h4", 0
  end
end
