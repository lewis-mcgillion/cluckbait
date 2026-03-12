require "test_helper"

class WishlistItemTest < ActiveSupport::TestCase
  # -- Associations --

  test "belongs to a user" do
    item = create(:wishlist_item)
    assert_instance_of User, item.user
  end

  test "belongs to a chicken shop" do
    item = create(:wishlist_item)
    assert_instance_of ChickenShop, item.chicken_shop
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:wishlist_item).valid?
  end

  test "invalid without user" do
    item = build(:wishlist_item, user: nil)
    assert_not item.valid?
  end

  test "invalid without chicken_shop" do
    item = build(:wishlist_item, chicken_shop: nil)
    assert_not item.valid?
  end

  test "enforces uniqueness of chicken_shop scoped to user" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:wishlist_item, user: user, chicken_shop: shop)

    duplicate = build(:wishlist_item, user: user, chicken_shop: shop)
    assert_not duplicate.valid?
    assert duplicate.errors[:chicken_shop_id].any?
  end

  test "same user can wishlist different shops" do
    user = create(:user)
    shop1 = create(:chicken_shop)
    shop2 = create(:chicken_shop)
    create(:wishlist_item, user: user, chicken_shop: shop1)

    assert build(:wishlist_item, user: user, chicken_shop: shop2).valid?
  end

  test "different users can wishlist the same shop" do
    shop = create(:chicken_shop)
    user1 = create(:user)
    user2 = create(:user)
    create(:wishlist_item, user: user1, chicken_shop: shop)

    assert build(:wishlist_item, user: user2, chicken_shop: shop).valid?
  end

  # -- Defaults --

  test "visited defaults to false" do
    item = create(:wishlist_item)
    assert_equal false, item.visited
  end

  test "notes are optional" do
    assert build(:wishlist_item, notes: nil).valid?
    assert build(:wishlist_item, notes: "").valid?
    assert build(:wishlist_item, notes: "Must try this place!").valid?
  end

  # -- Scopes --

  test "want_to_try scope returns unvisited items" do
    item1 = create(:wishlist_item, visited: false)
    item2 = create(:wishlist_item, :visited)

    results = WishlistItem.want_to_try
    assert_includes results, item1
    assert_not_includes results, item2
  end

  test "visited scope returns visited items" do
    item1 = create(:wishlist_item, visited: false)
    item2 = create(:wishlist_item, :visited)

    results = WishlistItem.visited
    assert_not_includes results, item1
    assert_includes results, item2
  end

  test "recent scope orders by created_at descending" do
    old_item = create(:wishlist_item, created_at: 2.days.ago)
    new_item = create(:wishlist_item, created_at: 1.hour.ago)

    results = WishlistItem.recent.to_a
    assert results.index(new_item) < results.index(old_item)
  end

  # -- User associations --

  test "user has_many wishlist_items" do
    user = create(:user)
    shop = create(:chicken_shop)
    item = create(:wishlist_item, user: user, chicken_shop: shop)

    assert_includes user.wishlist_items, item
  end

  test "user has_many wishlisted_shops through wishlist_items" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:wishlist_item, user: user, chicken_shop: shop)

    assert_includes user.wishlisted_shops, shop
  end

  test "destroying user destroys wishlist items" do
    user = create(:user)
    create(:wishlist_item, user: user)

    assert_difference "WishlistItem.count", -1 do
      user.destroy
    end
  end

  test "wishlisted? returns true for wishlisted shop" do
    user = create(:user)
    shop = create(:chicken_shop)
    create(:wishlist_item, user: user, chicken_shop: shop)

    assert user.wishlisted?(shop)
  end

  test "wishlisted? returns false for non-wishlisted shop" do
    user = create(:user)
    shop = create(:chicken_shop)

    assert_not user.wishlisted?(shop)
  end

  test "wishlist_count returns count of wishlist items" do
    user = create(:user)
    create(:wishlist_item, user: user)
    create(:wishlist_item, user: user)

    assert_equal 2, user.wishlist_count
  end
end
