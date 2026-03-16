class SocialAccount < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
  validates :provider, uniqueness: { scope: :user_id, message: "is already linked to your account" }

  PROVIDERS = %w[google_oauth2].freeze

  validates :provider, inclusion: { in: PROVIDERS }
end
