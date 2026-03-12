require "test_helper"

class WishlistItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @shop = create(:chicken_shop)
  end

  # -- Authentication --

  test "index redirects unauthenticated users" do
    get wishlist_items_path
    assert_redirected_to new_user_session_path
  end

  test "create redirects unauthenticated users" do
    post wishlist_items_path, params: { chicken_shop_id: @shop.id }
    assert_redirected_to new_user_session_path
  end

  test "update redirects unauthenticated users" do
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)
    patch wishlist_item_path(item)
    assert_redirected_to new_user_session_path
  end

  test "destroy redirects unauthenticated users" do
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)
    delete wishlist_item_path(item)
    assert_redirected_to new_user_session_path
  end

  # -- #index --

  test "index renders successfully" do
    sign_in @user
    get wishlist_items_path
    assert_response :success
  end

  test "index shows user wishlist items" do
    sign_in @user
    create(:wishlist_item, user: @user, chicken_shop: @shop)

    get wishlist_items_path
    assert_response :success
  end

  test "index filters by want_to_try" do
    sign_in @user
    create(:wishlist_item, user: @user, chicken_shop: @shop, visited: false)
    shop2 = create(:chicken_shop)
    create(:wishlist_item, user: @user, chicken_shop: shop2, visited: true)

    get wishlist_items_path(filter: "want_to_try")
    assert_response :success
  end

  test "index filters by visited" do
    sign_in @user
    create(:wishlist_item, user: @user, chicken_shop: @shop, visited: true)

    get wishlist_items_path(filter: "visited")
    assert_response :success
  end

  test "index does not show other users wishlist items" do
    sign_in @user
    other_user = create(:user)
    create(:wishlist_item, user: other_user, chicken_shop: @shop)

    get wishlist_items_path
    assert_response :success
  end

  # -- #create --

  test "create adds shop to wishlist" do
    sign_in @user

    assert_difference "WishlistItem.count", 1 do
      post wishlist_items_path, params: { chicken_shop_id: @shop.id }
    end
  end

  test "create assigns to current user" do
    sign_in @user

    post wishlist_items_path, params: { chicken_shop_id: @shop.id }
    item = WishlistItem.last
    assert_equal @user, item.user
    assert_equal @shop, item.chicken_shop
  end

  test "create responds with turbo_stream" do
    sign_in @user

    post wishlist_items_path, params: { chicken_shop_id: @shop.id }, as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "create with html format redirects on success" do
    sign_in @user

    post wishlist_items_path, params: { chicken_shop_id: @shop.id }
    assert_redirected_to @shop
    assert_equal "Added to your wishlist! 🔖", flash[:notice]
  end

  test "create with notes saves notes" do
    sign_in @user

    post wishlist_items_path, params: { chicken_shop_id: @shop.id, notes: "Must try the wings" }
    item = WishlistItem.last
    assert_equal "Must try the wings", item.notes
  end

  test "create duplicate shop fails" do
    sign_in @user
    create(:wishlist_item, user: @user, chicken_shop: @shop)

    assert_no_difference "WishlistItem.count" do
      post wishlist_items_path, params: { chicken_shop_id: @shop.id }
    end
  end

  # -- #update --

  test "update toggles visited status" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop, visited: false)

    patch wishlist_item_path(item)
    item.reload
    assert item.visited?
  end

  test "update toggles visited back to false" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop, visited: true)

    patch wishlist_item_path(item)
    item.reload
    assert_not item.visited?
  end

  test "update responds with turbo_stream" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)

    patch wishlist_item_path(item), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "update with html format redirects" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)

    patch wishlist_item_path(item)
    assert_redirected_to wishlist_items_path
  end

  test "update prevents modifying another users item" do
    sign_in @user
    other_user = create(:user)
    item = create(:wishlist_item, user: other_user, chicken_shop: @shop)

    patch wishlist_item_path(item)
    assert_response :not_found
  end

  # -- #destroy --

  test "destroy removes wishlist item" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)

    assert_difference "WishlistItem.count", -1 do
      delete wishlist_item_path(item)
    end
  end

  test "destroy responds with turbo_stream" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)

    delete wishlist_item_path(item), as: :turbo_stream
    assert_response :success
  end

  test "destroy with html format redirects" do
    sign_in @user
    item = create(:wishlist_item, user: @user, chicken_shop: @shop)

    delete wishlist_item_path(item)
    assert_redirected_to wishlist_items_path
  end

  test "destroy prevents deleting another users item" do
    sign_in @user
    other_user = create(:user)
    item = create(:wishlist_item, user: other_user, chicken_shop: @shop)

    delete wishlist_item_path(item)
    assert_response :not_found
  end
end
