class AdminAuditLog < ApplicationRecord
  belongs_to :admin_user, class_name: "User"

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def target
    return nil unless target_type.present? && target_id.present?

    target_type.constantize.find_by(id: target_id)
  end

  def parsed_metadata
    return {} if metadata.blank?

    JSON.parse(metadata)
  rescue JSON::ParserError
    {}
  end
end
