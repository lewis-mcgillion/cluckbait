class ReviewReaction < ApplicationRecord
  KINDS = %w[fire thumbs_up heart_eyes laugh helpful not_helpful].freeze

  belongs_to :user
  belongs_to :review

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :kind, uniqueness: { scope: [:user_id, :review_id], message: "already reacted with this kind" }

  after_create :evaluate_badges

  private

  def evaluate_badges
    return unless kind == "helpful"

    # Award badges to the review author who received the helpful reaction
    AwardBadgeJob.perform_later(review.user_id, categories: %w[reactions])
  end
end
