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
end
