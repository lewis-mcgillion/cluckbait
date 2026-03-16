class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :icon, presence: true
  validates :category, presence: true
  validates :threshold, presence: true, numericality: { greater_than: 0 }

  DEFINITIONS = [
    {
      key: "first_cluck", name: "First Cluck", description: "Write your first review",
      icon: "🐣", category: "reviews", threshold: 1
    },
    {
      key: "wing_warrior", name: "Wing Warrior", description: "Review 10 different shops",
      icon: "🍗", category: "reviews", threshold: 10
    },
    {
      key: "bucket_lister", name: "Bucket Lister", description: "Review 25 shops",
      icon: "🪣", category: "reviews", threshold: 25
    },
    {
      key: "colonel", name: "Colonel", description: "Review 50 shops",
      icon: "🎖️", category: "reviews", threshold: 50
    },
    {
      key: "golden_drumstick", name: "Golden Drumstick", description: "Review 100 shops",
      icon: "🏆", category: "reviews", threshold: 100
    },
    {
      key: "shutterbug", name: "Shutterbug", description: "Upload 50 review photos",
      icon: "📸", category: "photos", threshold: 50
    },
    {
      key: "helpful_hen", name: "Helpful Hen",
      description: "Receive 50 helpful reactions on reviews",
      icon: "🐔", category: "reactions", threshold: 50
    },
    {
      key: "social_butterfly", name: "Social Butterfly", description: "Make 10 friends",
      icon: "🦋", category: "social", threshold: 10
    },
    {
      key: "explorer", name: "Explorer", description: "Visit shops in 5 different cities",
      icon: "🗺️", category: "exploration", threshold: 5
    },
    {
      key: "wishlist_wizard", name: "Wishlist Wizard",
      description: "Add 20 shops to wishlist and visit them all",
      icon: "🧙", category: "wishlist", threshold: 20
    }
  ].freeze

  scope :ordered, -> { order(:category, :threshold) }

  def self.seed!
    DEFINITIONS.each do |attrs|
      find_or_create_by!(key: attrs[:key]) do |badge|
        badge.assign_attributes(attrs)
      end
    end
  end

  # Returns the current progress count for a user toward this badge
  def progress_for(user)
    BadgeEvaluator.progress(user, key)
  end

  def earned_by?(user)
    user_badges.exists?(user: user)
  end
end
