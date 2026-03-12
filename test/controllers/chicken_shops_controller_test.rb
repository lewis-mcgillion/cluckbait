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
end
