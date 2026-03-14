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

  # -- Friendship routes --

  test "friendships index route" do
    assert_routing "/friendships", controller: "friendships", action: "index"
  end

  test "friendships create route" do
    assert_routing({ method: "post", path: "/friendships" },
      controller: "friendships", action: "create")
  end

  test "friendships update route" do
    assert_routing({ method: "patch", path: "/friendships/1" },
      controller: "friendships", action: "update", id: "1")
  end

  test "friendships destroy route" do
    assert_routing({ method: "delete", path: "/friendships/1" },
      controller: "friendships", action: "destroy", id: "1")
  end

  # -- Conversation routes --

  test "conversations index route" do
    assert_routing "/conversations", controller: "conversations", action: "index"
  end

  test "conversations show route" do
    assert_routing "/conversations/1", controller: "conversations", action: "show", id: "1"
  end

  test "conversations create route" do
    assert_routing({ method: "post", path: "/conversations" },
      controller: "conversations", action: "create")
  end

  # -- Message routes --

  test "nested messages create route" do
    assert_routing({ method: "post", path: "/conversations/1/messages" },
      controller: "messages", action: "create", conversation_id: "1")
  end

  # -- Activity routes --

  test "activities index route" do
    assert_routing "/activities", controller: "activities", action: "index"
  end

  # -- Notification routes --

  test "notifications index route" do
    assert_routing "/notifications", controller: "notifications", action: "index"
  end

  test "notifications mark_as_read route" do
    assert_routing({ method: "patch", path: "/notifications/1/mark_as_read" },
      controller: "notifications", action: "mark_as_read", id: "1")
  end

  test "notifications mark_all_as_read route" do
    assert_routing({ method: "post", path: "/notifications/mark_all_as_read" },
      controller: "notifications", action: "mark_all_as_read")
  end

  # -- Wishlist routes --

  test "wishlist_items index route" do
    assert_routing "/wishlist_items", controller: "wishlist_items", action: "index"
  end

  test "wishlist_items create route" do
    assert_routing({ method: "post", path: "/wishlist_items" },
      controller: "wishlist_items", action: "create")
  end

  test "wishlist_items update route" do
    assert_routing({ method: "patch", path: "/wishlist_items/1" },
      controller: "wishlist_items", action: "update", id: "1")
  end

  test "wishlist_items destroy route" do
    assert_routing({ method: "delete", path: "/wishlist_items/1" },
      controller: "wishlist_items", action: "destroy", id: "1")
  end

  # -- Review reaction routes --

  test "nested review reactions create route" do
    assert_routing({ method: "post", path: "/reviews/1/reactions" },
      controller: "review_reactions", action: "create", review_id: "1")
  end
end
