require "test_helper"

class RoutingTest < ActionDispatch::IntegrationTest
  test "root routes to home#index" do
    assert_routing "/", controller: "home", action: "index"
  end

  test "chicken_shops index route" do
    assert_routing "/chicken_shops", controller: "chicken_shops", action: "index"
  end

  test "chicken_shops show route" do
    assert_routing "/chicken_shops/1", controller: "chicken_shops", action: "show", id: "1"
  end

  test "nested reviews create route" do
    assert_routing({ method: "post", path: "/chicken_shops/1/reviews" },
      controller: "reviews", action: "create", chicken_shop_id: "1")
  end

  test "nested reviews destroy route" do
    assert_routing({ method: "delete", path: "/chicken_shops/1/reviews/2" },
      controller: "reviews", action: "destroy", chicken_shop_id: "1", id: "2")
  end

  test "profiles show route" do
    assert_routing "/profiles/1", controller: "profiles", action: "show", id: "1"
  end

  test "profiles edit route" do
    assert_routing "/profiles/1/edit", controller: "profiles", action: "edit", id: "1"
  end

  test "profiles update route" do
    assert_routing({ method: "patch", path: "/profiles/1" },
      controller: "profiles", action: "update", id: "1")
  end

  test "api shops route" do
    assert_routing "/api/shops", controller: "api/shops", action: "index"
  end

  test "health check route" do
    get "/up"
    assert_response :success
  end

  test "no route for chicken_shops create" do
    post "/chicken_shops"
    assert_response :not_found
  end

  test "no route for chicken_shops edit" do
    get "/chicken_shops/1/edit"
    assert_response :not_found
  end
end
