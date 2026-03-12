require "test_helper"

class UserTest < ActiveSupport::TestCase
  # -- Associations --

  test "has many reviews" do
    assert_respond_to build(:user), :reviews
  end

  test "destroying user destroys associated reviews" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop)

    assert_difference "Review.count", -1 do
      user.destroy
    end
  end

  test "has one attached avatar" do
    assert_respond_to build(:user), :avatar
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:user).valid?
  end

  test "invalid without email" do
    user = build(:user, email: "")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "invalid without password" do
    user = build(:user, password: "")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "invalid with duplicate email" do
    create(:user, email: "taken@example.com")
    user = build(:user, email: "taken@example.com")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "display_name can be blank" do
    assert build(:user, display_name: "").valid?
  end

  test "display_name cannot exceed 50 characters" do
    user = build(:user, :with_long_display_name)
    assert_not user.valid?
    assert user.errors[:display_name].any?
  end

  test "display_name at exactly 50 characters is valid" do
    assert build(:user, display_name: "a" * 50).valid?
  end

  test "bio can be blank" do
    assert build(:user, bio: "").valid?
  end

  test "bio cannot exceed 500 characters" do
    user = build(:user, :with_long_bio)
    assert_not user.valid?
    assert user.errors[:bio].any?
  end

  test "bio at exactly 500 characters is valid" do
    assert build(:user, bio: "a" * 500).valid?
  end

  # -- #name --

  test "name returns display_name when present" do
    user = build(:user, display_name: "Alice")
    assert_equal "Alice", user.name
  end

  test "name falls back to email prefix when display_name is blank" do
    user = build(:user, email: "carol@example.com", display_name: "")
    assert_equal "carol", user.name
  end

  test "name returns fallback when email prefix is empty" do
    user = build(:user, email: "@example.com", display_name: "")
    assert_equal "?", user.name
  end

  # -- #avatar_url --

  test "avatar_url returns nil when no avatar attached" do
    assert_nil build(:user).avatar_url
  end

  # -- #reviews_count --

  test "reviews_count returns the number of reviews" do
    user = create(:user)
    shop1 = create(:chicken_shop)
    shop2 = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop1)
    create(:review, user: user, chicken_shop: shop2)

    assert_equal 2, user.reviews_count
  end

  test "reviews_count returns 0 when no reviews" do
    assert_equal 0, create(:user).reviews_count
  end

  # -- #average_rating_given --

  test "average_rating_given calculates correctly" do
    user = create(:user)
    shop1 = create(:chicken_shop)
    shop2 = create(:chicken_shop)
    create(:review, user: user, chicken_shop: shop1, rating: 5)
    create(:review, user: user, chicken_shop: shop2, rating: 3)

    assert_equal 4.0, user.average_rating_given
  end

  test "average_rating_given returns 0 when no reviews" do
    assert_equal 0, create(:user).average_rating_given
  end
end
