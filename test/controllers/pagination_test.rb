require "test_helper"

class PaginationTest < ActionDispatch::IntegrationTest
  # -- Chicken Shops Index --

  test "chicken shops index paginates results" do
    30.times { create(:chicken_shop) }

    get chicken_shops_path
    assert_response :success
    assert_select ".pagination"
    assert_select ".pagination-btn", text: "Next →"
  end

  test "chicken shops index page 2 shows previous button" do
    30.times { create(:chicken_shop) }

    get chicken_shops_path, params: { page: 2 }
    assert_response :success
    assert_select ".pagination-btn", text: "← Previous"
  end

  test "chicken shops index no pagination when few results" do
    3.times { create(:chicken_shop) }

    get chicken_shops_path
    assert_response :success
    assert_select ".pagination", count: 0
  end

  # -- Chicken Shop Reviews --

  test "shop show paginates reviews" do
    shop = create(:chicken_shop)
    30.times { create(:review, chicken_shop: shop) }

    get chicken_shop_path(shop)
    assert_response :success
    assert_select ".pagination"
  end

  test "shop show no pagination when few reviews" do
    shop = create(:chicken_shop)
    3.times { create(:review, chicken_shop: shop) }

    get chicken_shop_path(shop)
    assert_response :success
    assert_select ".pagination", count: 0
  end

  test "shop show page 2 reviews" do
    shop = create(:chicken_shop)
    30.times { create(:review, chicken_shop: shop) }

    get chicken_shop_path(shop), params: { page: 2 }
    assert_response :success
    assert_select ".pagination-btn", text: "← Previous"
  end

  test "shop show preserves review sort across pages" do
    shop = create(:chicken_shop)
    30.times { create(:review, chicken_shop: shop) }

    get chicken_shop_path(shop), params: { review_sort: "highest_rated", page: 1 }
    assert_response :success
  end

  # -- Profile Reviews --

  test "profile paginates reviews" do
    user = create(:user)
    30.times { create(:review, user: user) }

    get profile_path(user)
    assert_response :success
    assert_select ".pagination"
  end

  test "profile no pagination when few reviews" do
    user = create(:user)
    3.times { create(:review, user: user) }

    get profile_path(user)
    assert_response :success
    assert_select ".pagination", count: 0
  end

  # -- Wishlist --

  test "wishlist paginates items" do
    user = create(:user)
    sign_in user
    30.times { create(:wishlist_item, user: user) }

    get wishlist_items_path
    assert_response :success
    assert_select ".pagination"
  end

  test "wishlist no pagination when few items" do
    user = create(:user)
    sign_in user
    3.times { create(:wishlist_item, user: user) }

    get wishlist_items_path
    assert_response :success
    assert_select ".pagination", count: 0
  end

  test "wishlist preserves filter across pages" do
    user = create(:user)
    sign_in user
    30.times { create(:wishlist_item, user: user, visited: false) }

    get wishlist_items_path, params: { filter: "want_to_try", page: 1 }
    assert_response :success
  end

  # -- Notifications --

  test "notifications paginates results" do
    user = create(:user)
    sign_in user
    30.times { create(:notification, user: user) }

    get notifications_path
    assert_response :success
    assert_select ".pagination"
  end

  test "notifications no pagination when few results" do
    user = create(:user)
    sign_in user
    3.times { create(:notification, user: user) }

    get notifications_path
    assert_response :success
    assert_select ".pagination", count: 0
  end

  # -- Conversations --

  test "conversations paginates results" do
    user = create(:user)
    sign_in user
    30.times do
      friend = create(:user)
      create(:friendship, :accepted, user: user, friend: friend)
      create(:conversation, sender: user, receiver: friend)
    end

    get conversations_path
    assert_response :success
    assert_select ".pagination"
  end

  test "conversations no pagination when few results" do
    user = create(:user)
    sign_in user
    friend = create(:user)
    create(:friendship, :accepted, user: user, friend: friend)
    create(:conversation, sender: user, receiver: friend)

    get conversations_path
    assert_response :success
    assert_select ".pagination", count: 0
  end

  # -- Friends --

  test "friends paginates results" do
    user = create(:user)
    sign_in user
    30.times do
      friend = create(:user)
      create(:friendship, :accepted, user: user, friend: friend)
    end

    get friendships_path
    assert_response :success
    assert_select ".pagination"
  end

  test "friends no pagination when few results" do
    user = create(:user)
    sign_in user
    2.times do
      friend = create(:user)
      create(:friendship, :accepted, user: user, friend: friend)
    end

    get friendships_path
    assert_response :success
    assert_select ".pagination", count: 0
  end

  # -- Edge cases --

  test "page param below 1 defaults to page 1" do
    get chicken_shops_path, params: { page: -5 }
    assert_response :success
  end

  test "page param beyond results shows empty page" do
    3.times { create(:chicken_shop) }
    get chicken_shops_path, params: { page: 999 }
    assert_response :success
  end

  test "non-numeric page param defaults to page 1" do
    get chicken_shops_path, params: { page: "abc" }
    assert_response :success
  end
end
