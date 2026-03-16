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

  test "create with non-existent chicken shop returns not found" do
    sign_in @user

    post chicken_shop_reviews_path(chicken_shop_id: 999999), params: {
      review: { rating: 5, title: "Test", body: "Test body" }
    }
    assert_response :not_found
  end

  test "create with photo upload" do
    sign_in @user

    file = Tempfile.new(["test_image", ".jpg"])
    file.write("fake image data")
    file.rewind

    photo = Rack::Test::UploadedFile.new(file.path, "image/jpeg")

    assert_difference "Review.count", 1 do
      post chicken_shop_reviews_path(@shop), params: {
        review: {
          rating: 5,
          title: "With photo",
          body: "Check this out!",
          photos: [photo]
        }
      }
    end
  ensure
    file&.close
    file&.unlink
  end

  test "create with missing title fails" do
    sign_in @user

    assert_no_difference "Review.count" do
      post chicken_shop_reviews_path(@shop), params: {
        review: { rating: 5, title: "", body: "Some body text" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with missing body fails" do
    sign_in @user

    assert_no_difference "Review.count" do
      post chicken_shop_reviews_path(@shop), params: {
        review: { rating: 5, title: "Some title", body: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with missing rating fails" do
    sign_in @user

    assert_no_difference "Review.count" do
      post chicken_shop_reviews_path(@shop), params: {
        review: { rating: nil, title: "Some title", body: "Some body" }
      }
    end
    assert_response :unprocessable_entity
  end

  # -- #edit --

  test "can edit own review" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    get edit_chicken_shop_review_path(@shop, review)
    assert_response :success
  end

  test "cannot edit other user's review" do
    other_user = create(:user)
    review = create(:review, user: other_user, chicken_shop: @shop)
    sign_in @user

    get edit_chicken_shop_review_path(@shop, review)
    assert_response :not_found
  end

  test "edit redirects unauthenticated users" do
    review = create(:review, user: @user, chicken_shop: @shop)
    get edit_chicken_shop_review_path(@shop, review)
    assert_redirected_to new_user_session_path
  end

  # -- #update --

  test "can update own review" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    patch chicken_shop_review_path(@shop, review), params: {
      review: { title: "Updated Title", body: "Updated body text", rating: 4 }
    }

    assert_redirected_to @shop
    review.reload
    assert_equal "Updated Title", review.title
    assert_equal "Updated body text", review.body
    assert_equal 4, review.rating
  end

  test "cannot update other user's review" do
    other_user = create(:user)
    review = create(:review, user: other_user, chicken_shop: @shop)
    sign_in @user

    patch chicken_shop_review_path(@shop, review), params: {
      review: { title: "Hacked" }
    }
    assert_response :not_found
  end

  test "update with invalid data re-renders edit form" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    patch chicken_shop_review_path(@shop, review), params: {
      review: { title: "", body: "Still valid body", rating: 5 }
    }

    assert_response :unprocessable_entity
    review.reload
    assert_not_equal "", review.title
  end

  test "update responds with turbo_stream" do
    sign_in @user
    review = create(:review, user: @user, chicken_shop: @shop)

    patch chicken_shop_review_path(@shop, review), params: {
      review: { title: "Turbo Updated", body: "Updated via turbo", rating: 5 }
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html; charset=utf-8", response.content_type
  end

  test "update redirects unauthenticated users" do
    review = create(:review, user: @user, chicken_shop: @shop)

    patch chicken_shop_review_path(@shop, review), params: {
      review: { title: "Nope" }
    }
    assert_redirected_to new_user_session_path
  end

  test "validation errors displayed as sentence on create" do
    sign_in @user

    post chicken_shop_reviews_path(@shop), params: {
      review: { rating: nil, title: "", body: "" }
    }

    assert_response :unprocessable_entity
    assert flash[:alert].present?
    # to_sentence joins errors with ", " and "and"
    assert_match(/and/, flash[:alert])
  end
end
