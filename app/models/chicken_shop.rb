class ChickenShop < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reviews, dependent: :destroy
  has_many :wishlist_items, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :latitude, presence: { message: "must be set — please select a location on the map" }
  validates :longitude, presence: { message: "must be set — please select a location on the map" }
  validates :website, format: { with: /\Ahttps?:\/\/\S+\z/i, message: "must start with http:// or https://" },
allow_blank: true

  validate :acceptable_image

  scope :search_by_name, ->(query) {
    where(arel_table[:name].matches("%#{sanitize_sql_like(query)}%")) if query.present?
  }

  scope :search_by_city, ->(city) {
    where(arel_table[:city].matches("%#{sanitize_sql_like(city)}%")) if city.present?
  }

  scope :with_min_rating, ->(rating) {
    left_joins(:reviews)
      .group(:id)
      .having(ChickenShop.avg_rating_expr.gteq(rating.to_f))
  }

  scope :with_min_reviews, ->(count) {
    left_joins(:reviews)
      .group(:id)
      .having(ChickenShop.review_count_expr.gteq(count.to_i))
  }

  scope :with_photos, -> {
    where(id: Review.where(
      id: ActiveStorage::Attachment.where(record_type: "Review", name: "photos").select(:record_id)
    ).select(:chicken_shop_id))
  }

  scope :in_rating_range, ->(min, max) {
    left_joins(:reviews)
      .group(:id)
      .having(ChickenShop.avg_rating_expr.gteq(min.to_f).and(ChickenShop.avg_rating_expr.lteq(max.to_f)))
  }

  scope :by_highest_rated, -> {
    left_joins(:reviews)
      .group(:id)
      .order(ChickenShop.avg_rating_expr.desc)
  }

  scope :by_most_popular, -> {
    left_joins(:reviews)
      .group(:id)
      .order(ChickenShop.review_count_expr.desc)
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
    [address, city, postcode].compact.join(", ")
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

  def self.avg_rating_expr
    Arel::Nodes::NamedFunction.new("COALESCE", [
      Arel::Nodes::NamedFunction.new("AVG", [Review.arel_table[:rating]]),
      Arel::Nodes.build_quoted(0)
    ])
  end

  def self.review_count_expr
    Arel::Nodes::NamedFunction.new("COUNT", [Review.arel_table[:id]])
  end

  def self.select_with_stats
    select(
      arel_table[Arel.star],
      avg_rating_expr.as("avg_rating"),
      review_count_expr.as("review_count")
    )
  end

  private

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/png image/jpeg image/gif image/webp])
      errors.add(:image, "must be a PNG, JPEG, GIF, or WebP image")
    end

    if image.byte_size > 10.megabytes
      errors.add(:image, "must be less than 10 MB")
    end
  end
end
