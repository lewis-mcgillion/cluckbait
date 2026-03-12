class Review < ApplicationRecord
  belongs_to :user
  belongs_to :chicken_shop

  has_many_attached :photos

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :chicken_shop_id, message: "has already reviewed this shop" }

  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }

  def rating_label
    case rating
    when 5 then "Outstanding"
    when 4 then "Great"
    when 3 then "Good"
    when 2 then "Fair"
    when 1 then "Poor"
    end
  end
end
