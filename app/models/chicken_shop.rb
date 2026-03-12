class ChickenShop < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  scope :search_by_name, ->(query) { where("name LIKE ?", "%#{query}%") if query.present? }
  scope :search_by_city, ->(city) { where("city LIKE ?", "%#{city}%") if city.present? }

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

  scope :by_distance_from, ->(lat, lng) {
    order(Arel.sql(
      "((chicken_shops.latitude - #{lat.to_f}) * (chicken_shops.latitude - #{lat.to_f})) + " \
      "((chicken_shops.longitude - #{lng.to_f}) * (chicken_shops.longitude - #{lng.to_f})) ASC"
    ))
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
    (1..5).map { |r| [ r, reviews.where(rating: r).count ] }.to_h
  end

  def distance_from(lat, lng)
    return nil unless lat && lng
    rad = Math::PI / 180
    dlat = (latitude - lat) * rad
    dlng = (longitude - lng) * rad
    a = Math.sin(dlat / 2)**2 + Math.cos(lat * rad) * Math.cos(latitude * rad) * Math.sin(dlng / 2)**2
    6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end
end
