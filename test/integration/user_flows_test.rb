require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "visitor can browse home page" do
    get root_path
    assert_response :success
  end

  test "visitor can browse chicken shops index" do
    create(:chicken_shop, name: "Test Cluckers")
    get chicken_shops_path
    assert_response :success
  end

  test "visitor can view a chicken shop" do
    shop = create(:chicken_shop, name: "Cluck Palace")
    get chicken_shop_path(shop)
    assert_response :success
  end

  test "visitor can view a user profile" do
    user = create(:user, display_name: "ChickenFan")
    get profile_path(user)
    assert_response :success
  end

  test "visitor cannot create a review" do
    shop = create(:chicken_shop)
    post chicken_shop_reviews_path(shop), params: {
      review: { rating: 5, title: "Great", body: "Loved it" }
    }
    assert_redirected_to new_user_session_path
  end

  test "user can sign up" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          display_name: "NewCluckFan"
        }
      }
    end
    assert_redirected_to root_path
  end

  test "user can sign in and create a review" do
    user = create(:user)
    shop = create(:chicken_shop)

    sign_in user

    assert_difference "Review.count", 1 do
      post chicken_shop_reviews_path(shop), params: {
        review: { rating: 5, title: "Top notch", body: "Best burger in town" }
      }
    end
  end

  test "user can sign in and delete their own review" do
    user = create(:user)
    shop = create(:chicken_shop)
    review = create(:review, user: user, chicken_shop: shop)

    sign_in user

    assert_difference "Review.count", -1 do
      delete chicken_shop_review_path(shop, review)
    end
  end

  test "user can update their profile" do
    user = create(:user, display_name: "OldName")
    sign_in user

    patch profile_path(user), params: {
      user: { display_name: "NewName", bio: "Updated bio" }
    }

    assert_redirected_to profile_path(user)
    user.reload
    assert_equal "NewName", user.display_name
  end

  test "full flow: sign up, find shop, leave review" do
    shop = create(:chicken_shop, name: "Golden Cluck")

    # Sign up
    post user_registration_path, params: {
      user: {
        email: "flowtest@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to root_path
    follow_redirect!

    # Browse shops
    get chicken_shops_path
    assert_response :success

    # View shop
    get chicken_shop_path(shop)
    assert_response :success

    # Leave review
    assert_difference "Review.count", 1 do
      post chicken_shop_reviews_path(shop), params: {
        review: { rating: 5, title: "Perfect", body: "Absolutely fantastic burger" }
      }
    end
  end
end
