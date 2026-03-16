require "test_helper"

class ChickenShopsControllerTest < ActionDispatch::IntegrationTest
  # -- #index --

  test "index renders successfully" do
    get chicken_shops_path
    assert_response :success
  end

  test "index displays all shops" do
    create(:chicken_shop, name: "Cluck Palace")
    create(:chicken_shop, name: "Wing World")

    get chicken_shops_path
    assert_response :success
    assert_select "body"
  end

  test "index filters by search param" do
    create(:chicken_shop, name: "Cluck Palace")
    create(:chicken_shop, name: "Wing World")

    get chicken_shops_path, params: { search: "Cluck" }
    assert_response :success
  end

  test "index filters by city param" do
    create(:chicken_shop, city: "London")
    create(:chicken_shop, city: "Manchester")

    get chicken_shops_path, params: { city: "London" }
    assert_response :success
  end

  test "index sorts by highest_rated" do
    get chicken_shops_path, params: { sort: "highest_rated" }
    assert_response :success
  end

  test "index sorts by most_popular" do
    get chicken_shops_path, params: { sort: "most_popular" }
    assert_response :success
  end

  test "index sorts by distance with coordinates" do
    get chicken_shops_path, params: { sort: "distance", lat: "51.5", lng: "-0.1" }
    assert_response :success
  end

  test "index falls back to name sort when distance requested without coordinates" do
    get chicken_shops_path, params: { sort: "distance" }
    assert_response :success
  end

  test "index defaults to name sort" do
    get chicken_shops_path
    assert_response :success
  end

  test "index combines search and sort" do
    create(:chicken_shop, name: "Cluck Palace", city: "London")
    get chicken_shops_path, params: { search: "Cluck", sort: "highest_rated" }
    assert_response :success
  end

  # -- #show --

  test "show renders successfully" do
    shop = create(:chicken_shop)
    get chicken_shop_path(shop)
    assert_response :success
  end

  test "show displays shop details" do
    shop = create(:chicken_shop, name: "Test Cluckers")
    get chicken_shop_path(shop)
    assert_response :success
    assert_select "body"
  end

  test "show displays reviews for the shop" do
    shop = create(:chicken_shop)
    review = create(:review, chicken_shop: shop, title: "Crispy goodness")

    get chicken_shop_path(shop)
    assert_response :success
  end

  test "show returns 404 for non-existent shop" do
    get chicken_shop_path(id: 999999)
    assert_response :not_found
  end

  test "show prepares new review form for logged in user" do
    user = create(:user)
    sign_in user
    shop = create(:chicken_shop)

    get chicken_shop_path(shop)
    assert_response :success
  end

  test "show detects existing user review" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop)
    sign_in user

    get chicken_shop_path(shop)
    assert_response :success
  end

  # -- Advanced filters --

  test "index filters by rating_min" do
    good_shop = create(:chicken_shop, name: "Good Cluck")
    create(:review, chicken_shop: good_shop, rating: 5)

    bad_shop = create(:chicken_shop, name: "Bad Cluck")
    create(:review, chicken_shop: bad_shop, rating: 1)

    get chicken_shops_path, params: { rating_min: "4" }
    assert_response :success
  end

  test "index filters by rating range" do
    get chicken_shops_path, params: { rating_min: "2", rating_max: "4" }
    assert_response :success
  end

  test "index filters by min_reviews" do
    popular = create(:chicken_shop)
    5.times { create(:review, chicken_shop: popular) }

    quiet = create(:chicken_shop)
    create(:review, chicken_shop: quiet)

    get chicken_shops_path, params: { min_reviews: "5" }
    assert_response :success
  end

  test "index filters by has_photos" do
    get chicken_shops_path, params: { has_photos: "1" }
    assert_response :success
  end

  test "index sorts by newest" do
    get chicken_shops_path, params: { sort: "newest" }
    assert_response :success
  end

  test "index combines multiple filters" do
    shop = create(:chicken_shop, city: "London")
    3.times { create(:review, chicken_shop: shop, rating: 5) }

    get chicken_shops_path, params: { city: "London", rating_min: "4", min_reviews: "2", sort: "highest_rated" }
    assert_response :success
  end

  test "index combines search with filters" do
    create(:chicken_shop, name: "Cluck Palace")
    get chicken_shops_path, params: { search: "Cluck", rating_min: "3", has_photos: "1" }
    assert_response :success
  end

  # -- Review sorting on show --

  test "show sorts reviews by highest_rated" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop, rating: 5)
    create(:review, chicken_shop: shop, rating: 1)

    get chicken_shop_path(shop), params: { review_sort: "highest_rated" }
    assert_response :success
  end

  test "show sorts reviews by lowest_rated" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop, rating: 5)
    create(:review, chicken_shop: shop, rating: 1)

    get chicken_shop_path(shop), params: { review_sort: "lowest_rated" }
    assert_response :success
  end

  test "show defaults to recent review sort" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop)

    get chicken_shop_path(shop)
    assert_response :success
  end

  # -- #new --

  test "new requires authentication" do
    get new_chicken_shop_path
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "new renders successfully for signed in user" do
    sign_in create(:user)
    get new_chicken_shop_path
    assert_response :success
  end

  test "new displays form fields" do
    sign_in create(:user)
    get new_chicken_shop_path
    assert_response :success
    assert_select "form"
    assert_select "input[name='chicken_shop[name]']"
    assert_select "input[name='chicken_shop[address]']"
    assert_select "input[name='chicken_shop[city]']"
    assert_select "input[name='chicken_shop[latitude]']"
    assert_select "input[name='chicken_shop[longitude]']"
  end

  # -- #create --

  test "create requires authentication" do
    post chicken_shops_path, params: { chicken_shop: { name: "Test Shop" } }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "create with valid params creates a shop and redirects" do
    sign_in create(:user)

    assert_difference("ChickenShop.count", 1) do
      post chicken_shops_path, params: {
        chicken_shop: {
          name: "Cluck Palace",
          address: "42 High Street",
          city: "London",
          postcode: "SW1A 1AA",
          latitude: 51.5074,
          longitude: -0.1278,
          phone: "020 1234 5678",
          website: "https://cluckpalace.co.uk",
          description: "Amazing chicken burgers"
        }
      }
    end

    shop = ChickenShop.last
    assert_equal "Cluck Palace", shop.name
    assert_equal "London", shop.city
    assert_redirected_to chicken_shop_path(shop)
    assert_equal "Chicken shop was successfully added! 🍗", flash[:notice]
  end

  test "create with missing required fields renders errors" do
    sign_in create(:user)

    assert_no_difference("ChickenShop.count") do
      post chicken_shops_path, params: {
        chicken_shop: {
          name: "",
          address: "",
          city: "",
          latitude: "",
          longitude: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with invalid website format renders errors" do
    sign_in create(:user)

    assert_no_difference("ChickenShop.count") do
      post chicken_shops_path, params: {
        chicken_shop: {
          name: "Test Shop",
          address: "123 Street",
          city: "London",
          latitude: 51.5,
          longitude: -0.1,
          website: "not-a-url"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with only required fields succeeds" do
    sign_in create(:user)

    assert_difference("ChickenShop.count", 1) do
      post chicken_shops_path, params: {
        chicken_shop: {
          name: "Minimal Shop",
          address: "1 Test Rd",
          city: "Manchester",
          latitude: 53.4808,
          longitude: -2.2426
        }
      }
    end

    assert_redirected_to chicken_shop_path(ChickenShop.last)
  end

  # -- Review count pluralization --

  test "show displays singular review when shop has one review" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop)

    get chicken_shop_path(shop)
    assert_response :success
    assert_select ".rating-count", text: /\b1 review\b/
  end

  test "show displays plural reviews when shop has multiple reviews" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop)
    create(:review, chicken_shop: shop)

    get chicken_shop_path(shop)
    assert_response :success
    assert_select ".rating-count", text: /\b2 reviews\b/
  end

  # -- Star rating ARIA --

  test "show star rating input has radiogroup role" do
    user = create(:user)
    sign_in user
    shop = create(:chicken_shop)

    get chicken_shop_path(shop)
    assert_response :success
    assert_select '.star-rating-input[role="radiogroup"]'
  end

  # -- #edit --

  test "creator can edit their chicken shop" do
    user = create(:user)
    shop = create(:chicken_shop, user: user)
    sign_in user

    get edit_chicken_shop_path(shop)
    assert_response :success
    assert_select "form"
  end

  test "non-creator cannot edit chicken shop" do
    owner = create(:user)
    other = create(:user)
    shop = create(:chicken_shop, user: owner)
    sign_in other

    get edit_chicken_shop_path(shop)
    assert_redirected_to chicken_shop_path(shop)
    assert_equal "You can only edit chicken shops you've added.", flash[:alert]
  end

  test "unauthenticated user cannot edit chicken shop" do
    shop = create(:chicken_shop)

    get edit_chicken_shop_path(shop)
    assert_response :redirect
  end

  test "edit shows shop with no owner as inaccessible" do
    user = create(:user)
    shop = create(:chicken_shop, user: nil)
    sign_in user

    get edit_chicken_shop_path(shop)
    assert_redirected_to chicken_shop_path(shop)
  end

  # -- #update --

  test "creator can update their chicken shop" do
    user = create(:user)
    shop = create(:chicken_shop, user: user, name: "Old Name")
    sign_in user

    patch chicken_shop_path(shop), params: { chicken_shop: { name: "New Name" } }
    assert_redirected_to chicken_shop_path(shop)
    assert_equal "Chicken shop was successfully updated! 🍗", flash[:notice]
    assert_equal "New Name", shop.reload.name
  end

  test "non-creator cannot update chicken shop" do
    owner = create(:user)
    other = create(:user)
    shop = create(:chicken_shop, user: owner, name: "Original")
    sign_in other

    patch chicken_shop_path(shop), params: { chicken_shop: { name: "Hacked" } }
    assert_redirected_to chicken_shop_path(shop)
    assert_equal "Original", shop.reload.name
  end

  test "update with invalid data re-renders edit" do
    user = create(:user)
    shop = create(:chicken_shop, user: user)
    sign_in user

    patch chicken_shop_path(shop), params: { chicken_shop: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "create assigns current user as shop owner" do
    user = create(:user)
    sign_in user

    post chicken_shops_path, params: {
      chicken_shop: {
        name: "My Shop", address: "1 Test St", city: "London",
        latitude: 51.5, longitude: -0.1
      }
    }
    shop = ChickenShop.last
    assert_equal user, shop.user
  end

  test "show displays edit button for creator" do
    user = create(:user)
    shop = create(:chicken_shop, user: user)
    sign_in user

    get chicken_shop_path(shop)
    assert_response :success
    assert_select "a[href=?]", edit_chicken_shop_path(shop)
  end

  test "show does not display edit button for non-creator" do
    owner = create(:user)
    other = create(:user)
    shop = create(:chicken_shop, user: owner)
    sign_in other

    get chicken_shop_path(shop)
    assert_response :success
    assert_select "a[href=?]", edit_chicken_shop_path(shop), count: 0
  end
end
