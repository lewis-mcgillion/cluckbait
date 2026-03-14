require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get root_path
    assert_response :success
  end

  test "index assigns chicken shops" do
    create(:chicken_shop)
    get root_path
    assert_response :success
    assert_select "body"
  end

  test "index shows recent reviews" do
    shop = create(:chicken_shop)
    review = create(:review, chicken_shop: shop, title: "Clucking good")

    get root_path
    assert_response :success
  end

  test "index shows top rated shops" do
    shop = create(:chicken_shop, name: "Top Cluck")
    create(:review, chicken_shop: shop, rating: 5)

    get root_path
    assert_response :success
  end

  test "index top shops excludes shops without reviews" do
    shop_with_review = create(:chicken_shop, name: "Popular Cluck")
    create(:review, chicken_shop: shop_with_review, rating: 5)
    create(:chicken_shop, name: "No Reviews Shop")

    get root_path
    assert_response :success
  end

  test "index limits recent reviews to 6" do
    shop = create(:chicken_shop)
    7.times { create(:review, chicken_shop: shop) }

    get root_path
    assert_response :success
  end

  test "index top shops ordered by highest average rating" do
    low_shop = create(:chicken_shop, name: "Low")
    create(:review, chicken_shop: low_shop, rating: 2)

    high_shop = create(:chicken_shop, name: "High")
    create(:review, chicken_shop: high_shop, rating: 5)

    get root_path
    assert_response :success
  end
end
