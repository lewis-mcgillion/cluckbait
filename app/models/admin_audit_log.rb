class AdminAuditLog < ApplicationRecord
  belongs_to :admin_user, class_name: "User"

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def parsed_metadata
    return {} if metadata.blank?

    JSON.parse(metadata)
  rescue JSON::ParserError
    {}
  end
end
