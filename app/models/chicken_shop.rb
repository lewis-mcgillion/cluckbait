class ChickenShop < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :website, format: { with: /\Ahttps?:\/\/\S+\z/i, message: "must start with http:// or https://" }, allow_blank: true

  scope :search_by_name, ->(query) { where("name LIKE ?", "%#{query}%") if query.present? }
  scope :search_by_city, ->(city) { where("city LIKE ?", "%#{city}%") if city.present? }

  scope :with_min_rating, ->(rating) {
    left_joins(:reviews)
      .group(:id)
      .having("COALESCE(AVG(reviews.rating), 0) >= ?", rating.to_f)
  }

  scope :with_min_reviews, ->(count) {
    left_joins(:reviews)
      .group(:id)
      .having("COUNT(reviews.id) >= ?", count.to_i)
  }

  scope :with_photos, -> {
    where(
      "EXISTS (SELECT 1 FROM reviews " \
      "INNER JOIN active_storage_attachments ON active_storage_attachments.record_type = 'Review' " \
      "AND active_storage_attachments.record_id = reviews.id " \
      "AND active_storage_attachments.name = 'photos' " \
      "WHERE reviews.chicken_shop_id = chicken_shops.id)"
    )
  }

  scope :in_rating_range, ->(min, max) {
    left_joins(:reviews)
      .group(:id)
      .having("COALESCE(AVG(reviews.rating), 0) >= ? AND COALESCE(AVG(reviews.rating), 0) <= ?", min.to_f, max.to_f)
  }

  scope :by_highest_rated, -> {
    left_joins(:reviews)
      .group(:id)
      .order(Arel.sql("COALESCE(AVG(reviews.rating), 0) DESC"))
  }

  scope :by_most_popular, -> {
    left_joins(:reviews)
      .group(:id)
      .order(Arel.sql("COUNT(reviews.id) DESC"))
  }

  scope :by_newest, -> { order(created_at: :desc) }

  scope :by_distance_from, ->(lat, lng) {
    quoted_lat = Arel::Nodes.build_quoted(lat.to_f)
    quoted_lng = Arel::Nodes.build_quoted(lng.to_f)
    lat_diff = arel_table[:latitude] - quoted_lat
    lng_diff = arel_table[:longitude] - quoted_lng
    order((lat_diff * lat_diff) + (lng_diff * lng_diff))
  }

  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  def reviews_count
    reviews.count
  end

  def full_address
    [ address, city, postcode ].compact.join(", ")
  end

  def rating_distribution
    counts = reviews.group(:rating).count
    (1..5).index_with { |r| counts.fetch(r, 0) }
  end

  def distance_from(lat, lng)
    return nil unless lat && lng && latitude && longitude
    rad = Math::PI / 180
    dlat = (latitude - lat) * rad
    dlng = (longitude - lng) * rad
    a = Math.sin(dlat / 2)**2 + Math.cos(lat * rad) * Math.cos(latitude * rad) * Math.sin(dlng / 2)**2
    6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end
end
