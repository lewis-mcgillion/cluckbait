require "test_helper"

class ChickenShopTest < ActiveSupport::TestCase
  # -- Associations --

  test "has many reviews" do
    assert_respond_to build(:chicken_shop), :reviews
  end

  test "destroying shop destroys associated reviews" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop)

    assert_difference "Review.count", -1 do
      shop.destroy
    end
  end

  test "has one attached image" do
    assert_respond_to build(:chicken_shop), :image
  end

  # -- Validations --

  test "valid with all required attributes" do
    assert build(:chicken_shop).valid?
  end

  test "invalid without name" do
    shop = build(:chicken_shop, name: nil)
    assert_not shop.valid?
    assert_includes shop.errors[:name], "can't be blank"
  end

  test "invalid without address" do
    shop = build(:chicken_shop, address: nil)
    assert_not shop.valid?
    assert_includes shop.errors[:address], "can't be blank"
  end

  test "invalid without city" do
    shop = build(:chicken_shop, city: nil)
    assert_not shop.valid?
    assert_includes shop.errors[:city], "can't be blank"
  end

  test "invalid without latitude" do
    shop = build(:chicken_shop, latitude: nil)
    assert_not shop.valid?
    assert_includes shop.errors[:latitude], "can't be blank"
  end

  test "invalid without longitude" do
    shop = build(:chicken_shop, longitude: nil)
    assert_not shop.valid?
    assert_includes shop.errors[:longitude], "can't be blank"
  end

  test "valid with blank website" do
    assert build(:chicken_shop, website: "").valid?
  end

  test "valid with http website URL" do
    assert build(:chicken_shop, website: "http://example.com").valid?
  end

  test "valid with https website URL" do
    assert build(:chicken_shop, website: "https://example.com").valid?
  end

  test "invalid with website missing protocol" do
    shop = build(:chicken_shop, website: "example.com")
    assert_not shop.valid?
    assert shop.errors[:website].any?
  end

  test "invalid with website using ftp protocol" do
    shop = build(:chicken_shop, website: "ftp://example.com")
    assert_not shop.valid?
    assert shop.errors[:website].any?
  end

  # -- Scopes --

  test "search_by_name filters by partial name match" do
    create(:chicken_shop, name: "Sam's Chicken", city: "Northampton")
    create(:chicken_shop, name: "Morley's", city: "London")

    results = ChickenShop.search_by_name("Sam")
    assert_equal 1, results.count
    assert_equal "Sam's Chicken", results.first.name
  end

  test "search_by_name returns all when query is blank" do
    create_list_count = 2
    create(:chicken_shop)
    create(:chicken_shop)
    total = ChickenShop.count

    assert_equal total, ChickenShop.search_by_name("").count
    assert_equal total, ChickenShop.search_by_name(nil).count
  end

  test "search_by_city filters by partial city match" do
    create(:chicken_shop, city: "Northampton")
    create(:chicken_shop, city: "London")

    results = ChickenShop.search_by_city("North")
    assert_equal 1, results.count
  end

  test "by_highest_rated orders shops by average review rating descending" do
    top_shop = create(:chicken_shop)
    low_shop = create(:chicken_shop)
    create(:review, chicken_shop: top_shop, rating: 5)
    create(:review, chicken_shop: low_shop, rating: 1)

    shops = ChickenShop.by_highest_rated.to_a
    assert shops.index(top_shop) < shops.index(low_shop)
  end

  test "by_most_popular orders shops by review count descending" do
    popular = create(:chicken_shop)
    quiet = create(:chicken_shop)
    3.times { create(:review, chicken_shop: popular) }
    create(:review, chicken_shop: quiet)

    shops = ChickenShop.by_most_popular.to_a
    assert shops.index(popular) < shops.index(quiet)
  end

  test "by_distance_from orders by proximity to given coordinates" do
    near = create(:chicken_shop, :in_northampton)
    far = create(:chicken_shop, :in_manchester)

    shops = ChickenShop.by_distance_from(52.2405, -0.9027).to_a
    assert shops.index(near) < shops.index(far)
  end

  # -- #average_rating --

  test "average_rating returns rounded mean of review ratings" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop, rating: 5)
    create(:review, chicken_shop: shop, rating: 4)

    assert_equal 4.5, shop.average_rating
  end

  test "average_rating returns 0 when no reviews" do
    assert_equal 0, create(:chicken_shop).average_rating
  end

  # -- #reviews_count --

  test "reviews_count returns number of reviews" do
    shop = create(:chicken_shop)
    2.times { create(:review, chicken_shop: shop) }

    assert_equal 2, shop.reviews_count
  end

  test "reviews_count returns 0 when no reviews" do
    assert_equal 0, create(:chicken_shop).reviews_count
  end

  # -- #full_address --

  test "full_address joins address, city, and postcode" do
    shop = build(:chicken_shop, address: "123 High Street", city: "Northampton", postcode: "NN1 2AA")
    assert_equal "123 High Street, Northampton, NN1 2AA", shop.full_address
  end

  test "full_address omits nil postcode" do
    shop = build(:chicken_shop, :without_postcode, address: "1 Main St", city: "Leeds")
    assert_equal "1 Main St, Leeds", shop.full_address
  end

  # -- #rating_distribution --

  test "rating_distribution returns hash of rating counts" do
    shop = create(:chicken_shop)
    create(:review, chicken_shop: shop, rating: 5)
    create(:review, chicken_shop: shop, rating: 4)

    assert_equal({ 1 => 0, 2 => 0, 3 => 0, 4 => 1, 5 => 1 }, shop.rating_distribution)
  end

  test "rating_distribution returns all zeros when no reviews" do
    shop = create(:chicken_shop)
    assert_equal({ 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }, shop.rating_distribution)
  end

  # -- #distance_from --

  test "distance_from calculates Haversine distance in km" do
    shop = build(:chicken_shop, :in_northampton)
    distance = shop.distance_from(51.5074, -0.1278)
    assert_in_delta 100, distance, 20, "Northampton to London should be roughly 100km"
  end

  test "distance_from returns 0 for same coordinates" do
    shop = build(:chicken_shop, latitude: 51.5, longitude: -0.1)
    assert_in_delta 0, shop.distance_from(51.5, -0.1), 0.01
  end

  test "distance_from returns nil when lat or lng is nil" do
    shop = build(:chicken_shop)
    assert_nil shop.distance_from(nil, -0.1)
    assert_nil shop.distance_from(51.5, nil)
  end

  test "distance_from returns nil when shop latitude or longitude is nil" do
    shop = build(:chicken_shop, latitude: nil, longitude: nil)
    assert_nil shop.distance_from(51.5, -0.1)

    shop_no_lat = build(:chicken_shop, latitude: nil, longitude: -0.1)
    assert_nil shop_no_lat.distance_from(51.5, -0.1)

    shop_no_lng = build(:chicken_shop, latitude: 51.5, longitude: nil)
    assert_nil shop_no_lng.distance_from(51.5, -0.1)
  end

  # -- with_min_rating --

  test "with_min_rating returns shops with average rating at or above threshold" do
    good_shop = create(:chicken_shop)
    create(:review, chicken_shop: good_shop, rating: 5)
    create(:review, chicken_shop: good_shop, rating: 4)

    bad_shop = create(:chicken_shop)
    create(:review, chicken_shop: bad_shop, rating: 2)

    results = ChickenShop.with_min_rating(4)
    assert_includes results, good_shop
    assert_not_includes results, bad_shop
  end

  test "with_min_rating excludes shops with no reviews" do
    create(:chicken_shop)
    results = ChickenShop.with_min_rating(1)
    assert_empty results
  end

  # -- with_min_reviews --

  test "with_min_reviews returns shops with at least N reviews" do
    popular = create(:chicken_shop)
    3.times { create(:review, chicken_shop: popular) }

    quiet = create(:chicken_shop)
    create(:review, chicken_shop: quiet)

    results = ChickenShop.with_min_reviews(3)
    assert_includes results, popular
    assert_not_includes results, quiet
  end

  test "with_min_reviews excludes shops with no reviews" do
    create(:chicken_shop)
    results = ChickenShop.with_min_reviews(1)
    assert_empty results
  end

  # -- with_photos --

  test "with_photos returns shops that have reviews with photos" do
    shop_with_photo = create(:chicken_shop)
    review = create(:review, chicken_shop: shop_with_photo)
    review.photos.attach(
      io: StringIO.new("fake image"),
      filename: "photo.jpg",
      content_type: "image/jpeg"
    )

    shop_without_photo = create(:chicken_shop)
    create(:review, chicken_shop: shop_without_photo)

    results = ChickenShop.with_photos
    assert_includes results, shop_with_photo
    assert_not_includes results, shop_without_photo
  end

  test "with_photos excludes shops with no reviews" do
    create(:chicken_shop)
    assert_empty ChickenShop.with_photos
  end

  # -- in_rating_range --

  test "in_rating_range returns shops with average rating within range" do
    mid_shop = create(:chicken_shop)
    create(:review, chicken_shop: mid_shop, rating: 3)

    high_shop = create(:chicken_shop)
    create(:review, chicken_shop: high_shop, rating: 5)

    low_shop = create(:chicken_shop)
    create(:review, chicken_shop: low_shop, rating: 1)

    results = ChickenShop.in_rating_range(2, 4)
    assert_includes results, mid_shop
    assert_not_includes results, high_shop
    assert_not_includes results, low_shop
  end

  # -- by_newest --

  test "by_newest orders shops by creation date descending" do
    old_shop = create(:chicken_shop, created_at: 2.days.ago)
    new_shop = create(:chicken_shop, created_at: 1.hour.ago)

    shops = ChickenShop.by_newest.to_a
    assert shops.index(new_shop) < shops.index(old_shop)
  end
end
