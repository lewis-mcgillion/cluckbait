module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!

    layout "admin"

    private

    def authenticate_admin!
      authenticate_user!
      return if current_user.admin?

      redirect_to root_path, alert: "You are not authorised to access this area."
    end

    def audit!(action, target: nil, metadata: nil)
      AdminAuditLog.create!(
        admin_user: current_user,
        action: action,
        target_type: target&.class&.name,
        target_id: target&.id,
        metadata: metadata&.to_json
      )
    end

    def sanitize_sql_like(string)
      ActiveRecord::Base.sanitize_sql_like(string)
    end
  end
end
