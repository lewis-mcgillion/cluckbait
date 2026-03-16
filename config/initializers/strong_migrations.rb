# Mark existing migrations as safe so strong_migrations only checks new ones
StrongMigrations.start_after = 20260316162500

# Raise errors in CI/test, log warnings in production
StrongMigrations.lock_timeout = 10.seconds
StrongMigrations.statement_timeout = 1.hour
