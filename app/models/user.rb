class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :reviews, dependent: :destroy
  has_one_attached :avatar

  validates :display_name, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  def name
    display_name.presence || email.split("@").first
  end

  def avatar_url
    if avatar.attached?
      avatar
    end
  end

  def reviews_count
    reviews.count
  end

  def average_rating_given
    reviews.average(:rating)&.round(1) || 0
  end
end
