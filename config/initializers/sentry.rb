Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Sample rate for error events (1.0 = 100% of errors reported)
  config.sample_rate = 1.0

  # Performance monitoring (10% of transactions in production)
  config.traces_sample_rate = Rails.env.production? ? 0.1 : 0.0

  config.enabled_environments = %w[production]

  # Set the release version for tracking deployments
  config.release = ENV["GIT_REVISION"] || "unknown"

  # Disable automatic PII collection (user IPs, emails, headers) for privacy compliance
  config.send_default_pii = false

  # Exclude common bot/scanner noise
  config.excluded_exceptions += [
    "ActionController::RoutingError",
    "ActionController::BadRequest"
  ]
end
