class Review < ApplicationRecord
  belongs_to :user
  belongs_to :chicken_shop

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
    reactions_table = ReviewReaction.arel_table
    helpful_case = Arel::Nodes::Case.new
      .when(reactions_table[:kind].eq("helpful")).then(1)
      .when(reactions_table[:kind].eq("not_helpful")).then(-1)
      .else(0)
    score = Arel::Nodes::NamedFunction.new("COALESCE", [
      Arel::Nodes::NamedFunction.new("SUM", [helpful_case]),
      Arel::Nodes.build_quoted(0)
    ])

    left_joins(:reactions)
      .group(:id)
      .order(score.desc)
  }

  after_create :create_activity
  after_create_commit :broadcast_review

  def reactions_summary
    reactions.group(:kind).count
  end

  def helpful_score
    reactions.where(kind: "helpful").count - reactions.where(kind: "not_helpful").count
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
    Activity.create!(user: user, action: "posted_review", trackable: self)
  rescue => e
    Rails.logger.error("Failed to create activity for review #{id}: #{e.message}")
  end

  def broadcast_review
    broadcast_prepend_to(
      chicken_shop, :reviews,
      target: "reviews_list",
      partial: "reviews/review_card",
      locals: { review: self, chicken_shop: chicken_shop, current_user: nil }
    )
  rescue => e
    Rails.logger.error("Failed to broadcast review #{id}: #{e.message}")
  end
end
