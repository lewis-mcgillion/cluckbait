module Admin
  class AuditLogsController < BaseController
    PER_PAGE = 50

    def index
      @page = [(params[:page] || 1).to_i, 1].max
      @audit_logs = AdminAuditLog.includes(:admin_user).recent
      if params[:search].present?
        search = "%#{sanitize_sql_like(params[:search])}%"
        @audit_logs = @audit_logs.where("action LIKE ?", search)
      end

      fetched = @audit_logs.limit(PER_PAGE + 1).offset((@page - 1) * PER_PAGE).to_a
      @has_next_page = fetched.length > PER_PAGE
      @audit_logs = @has_next_page ? fetched.first(PER_PAGE) : fetched
    end
  end
end
