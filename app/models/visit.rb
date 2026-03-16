class Visit < ApplicationRecord
  validates :ip_address, presence: true
  validates :visited_at, presence: true

  scope :unique_count, -> { distinct.count(:ip_address) }
end
