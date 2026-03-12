require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @shop = create(:chicken_shop)
  end

  # -- Authentication --

  test "create redirects unauthenticated users" do
    post chicken_shop_reviews_path(@shop), params: {
      review: { rating: 5, title: "Great", body: "Loved it" }
    }
    assert_redirected_to new_user_session_path
  end

  test "destroy redirects unauthenticated users" do
    review = create(:review, user: @user, chicken_shop: @shop)
    delete chicken_shop_review_path(@shop, review)
    assert_redirected_to new_user_session_path
  end

  # -- #create --

  test "create with valid params creates a review" do
    sign_in @user

    assert_difference "Review.count", 1 do
      post chicken_shop_reviews_path(@shop), params: {
        review: { rating: 5, title: "Amazing", body: "Best chicken ever" }
      }
    end
  end

  test "create assigns review to current user" do
    sign_in @user

    post chicken_shop_reviews_path(@shop), params: {
      review: { rating: 4, title: "Good", body: "Solid chicken" }
    }

    review = Review.last
    assert_equal @user, review.user
    assert_equal @shop, review.chicken_shop
  end

  test "create responds with turbo_stream" do
    sign_in @user

    post chicken_shop_reviews_path(@shop), params: {
      review: { rating: 5, title: "Tasty", body: "Really good" }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "create with html format redirects on success" do
    sign_in @user

    post chicken_shop_reviews_path(@shop), params: {
      review: { rating: 5, title: "Tasty", body: "Really good" }
    }

    assert_redirected_to @shop
    assert_equal "Review posted successfully! 🍗", flash[:notice]
  end

  test "create with invalid params does not create a review" do
    sign_in @user

    assert_no_difference "Review.count" do
      post chicken_shop_reviews_path(@shop), params: {
        review: { rating: nil, title: "", body: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with duplicate user+shop pair fails" do
    sign_in @user
    create(:review, user: @user, chicken_shop: @shop)

    assert_no_difference "Review.count" do
      post chicken_shop_reviews_path(@shop), params: {
        review: { rating: 3, title: "Again", body: "Second attempt" }
      }
    end
    assert_response :unprocessable_entity
  end

  # -- #destroy --

  test "destroy removes the review" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    assert_difference "Review.count", -1 do
      delete chicken_shop_review_path(@shop, review)
    end
  end

  test "destroy responds with turbo_stream" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    delete chicken_shop_review_path(@shop, review), as: :turbo_stream
    assert_response :success
  end

  test "destroy with html format redirects" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    delete chicken_shop_review_path(@shop, review)
    assert_redirected_to @shop
  end

  test "destroy prevents deleting another users review" do
    other_user = create(:user)
    review = create(:review, user: other_user, chicken_shop: @shop)
    sign_in @user

    delete chicken_shop_review_path(@shop, review)
    assert_response :not_found
  end
end
