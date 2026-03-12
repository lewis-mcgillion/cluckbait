require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  # -- Associations --

  test "belongs to a user" do
    review = create(:review)
    assert_instance_of User, review.user
  end

  test "belongs to a chicken shop" do
    review = create(:review)
    assert_instance_of ChickenShop, review.chicken_shop
  end

  test "has many attached photos" do
    assert_respond_to build(:review), :photos
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:review).valid?
  end

  test "invalid without rating" do
    review = build(:review, rating: nil)
    assert_not review.valid?
    assert review.errors[:rating].any?
  end

  test "invalid with rating below 1" do
    review = build(:review, rating: 0)
    assert_not review.valid?
    assert review.errors[:rating].any?
  end

  test "invalid with rating above 5" do
    review = build(:review, rating: 6)
    assert_not review.valid?
    assert review.errors[:rating].any?
  end

  test "valid with rating at boundary 1" do
    assert build(:review, rating: 1).valid?
  end

  test "valid with rating at boundary 5" do
    assert build(:review, rating: 5).valid?
  end

  test "invalid without title" do
    review = build(:review, title: "")
    assert_not review.valid?
    assert review.errors[:title].any?
  end

  test "invalid with title over 100 characters" do
    review = build(:review, :with_long_title)
    assert_not review.valid?
    assert review.errors[:title].any?
  end

  test "title at exactly 100 characters is valid" do
    assert build(:review, title: "a" * 100).valid?
  end

  test "invalid without body" do
    review = build(:review, body: "")
    assert_not review.valid?
    assert review.errors[:body].any?
  end

  test "invalid with body over 2000 characters" do
    review = build(:review, :with_long_body)
    assert_not review.valid?
    assert review.errors[:body].any?
  end

  test "body at exactly 2000 characters is valid" do
    assert build(:review, body: "a" * 2000).valid?
  end

  test "enforces one review per user per shop" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop)

    duplicate = build(:review, user: user, chicken_shop: shop)
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can review different shops" do
    user = create(:user)
    shop1 = create(:chicken_shop)
    shop2 = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop1)

    assert build(:review, user: user, chicken_shop: shop2).valid?
  end

  test "different users can review the same shop" do
    shop = create(:chicken_shop)
    user1 = create(:user)
    user2 = create(:user)
    create(:review, user: user1, chicken_shop: shop)

    assert build(:review, user: user2, chicken_shop: shop).valid?
  end

  # -- Scopes --

  test "recent scope orders by created_at descending" do
    shop = create(:chicken_shop)
    old_review = create(:review, chicken_shop: shop, created_at: 2.days.ago)
    new_review = create(:review, chicken_shop: shop, created_at: 1.hour.ago)

    results = Review.recent.to_a
    assert results.index(new_review) < results.index(old_review)
  end

  test "highest_rated scope orders by rating descending" do
    shop = create(:chicken_shop)
    low = create(:review, chicken_shop: shop, rating: 1)
    high = create(:review, chicken_shop: shop, rating: 5)

    results = Review.highest_rated.to_a
    assert results.index(high) < results.index(low)
  end

  # -- #rating_label --

  test "rating_label returns Outstanding for 5" do
    assert_equal "Outstanding", build(:review, rating: 5).rating_label
  end

  test "rating_label returns Great for 4" do
    assert_equal "Great", build(:review, rating: 4).rating_label
  end

  test "rating_label returns Good for 3" do
    assert_equal "Good", build(:review, rating: 3).rating_label
  end

  test "rating_label returns Fair for 2" do
    assert_equal "Fair", build(:review, rating: 2).rating_label
  end

  test "rating_label returns Poor for 1" do
    assert_equal "Poor", build(:review, rating: 1).rating_label
  end
end
