class Review < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :chicken_shop, counter_cache: true

  has_many :reactions, class_name: "ReviewReaction", dependent: :destroy
  has_many_attached :photos

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :chicken_shop_id, message: "has already reviewed this shop" }

  validate :acceptable_photos

  scope :recent, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(rating: :desc) }
  scope :lowest_rated, -> { order(rating: :asc) }
  scope :by_most_helpful, -> {
    left_joins(:reactions)
      .group(:id)
      .order(
        Arel.sql("COALESCE(SUM(CASE WHEN review_reactions.kind = 'helpful' THEN 1 WHEN review_reactions.kind = 'not_helpful' THEN -1 ELSE 0 END), 0) DESC")
      )
  }

  after_create :create_activity

  def reactions_summary
    reactions.group(:kind).count
  end

  def helpful_score
    counts = reactions.where(kind: %w[helpful not_helpful]).group(:kind).count
    counts.fetch("helpful", 0) - counts.fetch("not_helpful", 0)
  end

  def rating_label
    case rating
    when 5 then "Outstanding"
    when 4 then "Great"
    when 3 then "Good"
    when 2 then "Fair"
    when 1 then "Poor"
    end
  end

  private

  def acceptable_photos
    return unless photos.attached?

    photos.each do |photo|
      unless photo.blob.content_type.in?(%w[image/png image/jpeg image/gif image/webp])
        errors.add(:photos, "must be PNG, JPEG, GIF, or WebP images")
        break
      end

      if photo.blob.byte_size > 10.megabytes
        errors.add(:photos, "must each be less than 10MB")
        break
      end
    end
  end

  def create_activity
    CreateActivityJob.perform_later(user_id: user_id, action: "posted_review", trackable_type: "Review", trackable_id: id)
  end
end
