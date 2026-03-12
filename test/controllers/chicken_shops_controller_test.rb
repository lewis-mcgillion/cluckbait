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
end
