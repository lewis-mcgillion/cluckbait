class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :chicken_shop

  validates :chicken_shop_id, uniqueness: { scope: :user_id, message: "is already on your wishlist" }

  scope :want_to_try, -> { where(visited: false) }
  scope :visited, -> { where(visited: true) }
  scope :recent, -> { order(created_at: :desc) }

  after_update :evaluate_badges, if: :saved_change_to_visited?

  private

  def evaluate_badges
    return unless visited?

    AwardBadgeJob.perform_later(user_id, categories: %w[wishlist])
  end
end
