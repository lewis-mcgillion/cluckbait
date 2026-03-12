require "test_helper"

class Api::ShopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @london_shop = create(:chicken_shop, name: "London Cluckers", city: "London",
      postcode: "SW1A 1AA", latitude: 51.5074, longitude: -0.1278)
    @manchester_shop = create(:chicken_shop, :in_manchester)
  end

  test "index returns JSON" do
    get api_shops_path, as: :json
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "index returns all shops" do
    get api_shops_path, as: :json
    shops = JSON.parse(response.body)
    assert_equal 2, shops.length
  end

  test "index returns expected shop attributes" do
    get api_shops_path, as: :json
    shops = JSON.parse(response.body)
    shop = shops.find { |s| s["name"] == "London Cluckers" }

    assert_not_nil shop
    assert_equal "London", shop["city"]
    assert_equal "SW1A 1AA", shop["postcode"]
    assert_equal 51.5074, shop["latitude"]
    assert_equal(-0.1278, shop["longitude"])
    assert shop.key?("average_rating")
    assert shop.key?("reviews_count")
    assert shop.key?("url")
    assert shop.key?("id")
    assert shop.key?("address")
  end

  test "index filters by search name" do
    get api_shops_path, params: { search: "London" }, as: :json
    shops = JSON.parse(response.body)
    assert_equal 1, shops.length
    assert_equal "London Cluckers", shops.first["name"]
  end

  test "index filters by search city" do
    get api_shops_path, params: { search: "Manchester" }, as: :json
    shops = JSON.parse(response.body)
    assert_equal 1, shops.length
    assert_equal "Wing Stop", shops.first["name"]
  end

  test "index filters by search postcode" do
    get api_shops_path, params: { search: "SW1A" }, as: :json
    shops = JSON.parse(response.body)
    assert_equal 1, shops.length
    assert_equal "London Cluckers", shops.first["name"]
  end

  test "index filters by geolocation bounding box" do
    get api_shops_path, params: { lat: "51.5074", lng: "-0.1278" }, as: :json
    shops = JSON.parse(response.body)

    shop_names = shops.map { |s| s["name"] }
    assert_includes shop_names, "London Cluckers"
    assert_not_includes shop_names, "Wing Stop"
  end

  test "index returns empty array when no matches" do
    get api_shops_path, params: { search: "Nonexistent" }, as: :json
    shops = JSON.parse(response.body)
    assert_equal 0, shops.length
  end

  test "index includes shop url path" do
    get api_shops_path, as: :json
    shops = JSON.parse(response.body)
    shop = shops.first
    assert_match %r{/chicken_shops/\d+}, shop["url"]
  end

  test "index includes average_rating and reviews_count" do
    create(:review, chicken_shop: @london_shop, rating: 5)
    create(:review, chicken_shop: @london_shop, rating: 3)

    get api_shops_path, as: :json
    shops = JSON.parse(response.body)
    london = shops.find { |s| s["name"] == "London Cluckers" }

    assert_equal "4.0", london["average_rating"].to_s
    assert_equal 2, london["reviews_count"]
  end
end
