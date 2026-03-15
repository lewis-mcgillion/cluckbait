require "test_helper"

class Admin::ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :admin)
    @user = create(:user)
    @shop = create(:chicken_shop)
    @review = create(:review, user: @user, chicken_shop: @shop)
  end

  # -- Authorization --

  test "non-admin cannot access reviews" do
    sign_in @user
    get admin_reviews_path
    assert_redirected_to root_path
  end

  # -- Index --

  test "admin can view reviews index" do
    sign_in @admin
    get admin_reviews_path
    assert_response :success
  end

  test "admin can search reviews" do
    sign_in @admin
    get admin_reviews_path, params: { search: "chicken" }
    assert_response :success
  end

  test "admin can filter low rated reviews" do
    sign_in @admin
    create(:review, :one_star, user: create(:user), chicken_shop: @shop)
    get admin_reviews_path, params: { filter: "low_rated" }
    assert_response :success
  end

  test "admin can filter recent reviews" do
    sign_in @admin
    get admin_reviews_path, params: { filter: "recent" }
    assert_response :success
  end

  # -- Show --

  test "admin can view review details" do
    sign_in @admin
    get admin_review_path(@review)
    assert_response :success
  end

  # -- Destroy --

  test "admin can delete a review" do
    sign_in @admin
    assert_difference "Review.count", -1 do
      delete admin_review_path(@review)
    end
    assert_redirected_to admin_reviews_path
  end

  test "deleting a review creates an audit log" do
    sign_in @admin
    assert_difference "AdminAuditLog.count", 1 do
      delete admin_review_path(@review)
    end
    log = AdminAuditLog.last
    assert_equal "review.destroy", log.action
    assert_equal "Review", log.target_type
  end

  # -- Pagination --

  test "reviews index supports pagination" do
    sign_in @admin
    get admin_reviews_path, params: { page: 2 }
    assert_response :success
  end
end
