class SocialAccount < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
  validates :provider, uniqueness: { scope: :user_id, message: "is already linked to your account" }

  PROVIDERS = %w[google_oauth2 apple facebook].freeze

  validates :provider, inclusion: { in: PROVIDERS }

  def display_provider
    case provider
    when "google_oauth2" then "Google"
    when "apple" then "Apple"
    when "facebook" then "Facebook"
    end
  end
end
