class Review < ApplicationRecord
  belongs_to :user
  belongs_to :chicken_shop

  has_many :reactions, class_name: "ReviewReaction", dependent: :destroy
  has_many_attached :photos

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :chicken_shop_id, message: "has already reviewed this shop" }

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

  def create_activity
    Activity.create!(user: user, action: "posted_review", trackable: self)
  end
end
