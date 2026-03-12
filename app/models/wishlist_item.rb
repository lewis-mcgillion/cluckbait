class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :chicken_shop

  validates :chicken_shop_id, uniqueness: { scope: :user_id, message: "is already on your wishlist" }

  scope :want_to_try, -> { where(visited: false) }
  scope :visited, -> { where(visited: true) }
  scope :recent, -> { order(created_at: :desc) }
end
