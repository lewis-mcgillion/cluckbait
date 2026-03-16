# Local Installation & Setup

## Prerequisites

| Requirement | Version | Notes |
|---|---|---|
| Ruby | 3.1+ | Developed with 3.4.1 |
| Bundler | 2.x | `gem install bundler` |
| PostgreSQL | 14+ | `brew install postgresql@17` on macOS; `apt install postgresql libpq-dev` on Ubuntu |
| Node.js | Not required | Importmap handles JS — no Node build step |

## Quick Setup (Recommended)

```bash
git clone https://github.com/lewis-mcgillion/cluckbait.git
cd cluckbait
bin/setup
```

`bin/setup` will:

1. Install gem dependencies via Bundler
2. Create the PostgreSQL databases
3. Run all migrations
4. Seed 250 shops, 5 users, and 992 reviews
5. Start the dev server

Visit [http://localhost:3000](http://localhost:3000) when it finishes.

## Manual Setup

```bash
git clone https://github.com/lewis-mcgillion/cluckbait.git
cd cluckbait

# Install gems
bundle install

# Create database, run migrations, and seed data
bin/rails db:create db:migrate db:seed

# Start the server
bin/rails server
```

Then visit [http://localhost:3000](http://localhost:3000).

## Environment Variables

The app runs with zero required env vars in development. All optional:

| Variable | Default | Purpose |
|---|---|---|
| `DEVISE_MAILER_SENDER` | `noreply@cluckbait.com` | From address for Devise emails |
| `GOOGLE_CLIENT_ID` | not set | Google OAuth client ID (required for Google sign-in) |
| `GOOGLE_CLIENT_SECRET` | not set | Google OAuth client secret (required for Google sign-in) |
| `SENTRY_DSN` | not set | Sentry error tracking DSN (production) |
| `REDIS_URL` | not set (Solid Cable used) | Action Cable adapter for production |
| `RAILS_MASTER_KEY` | read from `config/master.key` | Decrypt credentials in production |

## Database

PostgreSQL is used for all environments. In development, the databases are `cluckbait_development` and `cluckbait_test`. Ensure PostgreSQL is running locally before starting the app.

### Re-seeding

```bash
bin/rails db:seed
```

Seeds are idempotent — they use `find_or_create_by!` so you can re-run without duplicating data.

### Resetting

```bash
bin/rails db:reset    # Drops, creates, migrates, and seeds
```

## Running Tests

```bash
bin/rails test
```

Tests run in parallel across all available CPU cores. The suite uses Minitest with FactoryBot for fixtures.

Expected output: **341 tests, 620 assertions, 0 failures, 0 errors**.

## Linting

```bash
bin/rubocop -f github
```

Uses [rubocop-github](https://github.com/github/rubocop-github) — GitHub's Ruby style config, with rubocop-performance, rubocop-minitest, and rubocop-rails plugins.

## Docker

A production-ready `Dockerfile` is included:

```bash
docker build -t cluckbait .
docker run -p 3000:80 cluckbait
```

The Dockerfile uses a multi-stage build:

1. **Base** — Ruby 3.4.1 slim image with runtime dependencies
2. **Build** — Installs gems, precompiles assets and bootsnap cache
3. **Final** — Copies only what's needed, runs as non-root user (`rails:1000`)

The container starts with [Thruster](https://github.com/basecamp/thruster) (HTTP caching/compression proxy) in front of the Rails server on port 80.

## Deployment

### GitHub Actions CI/CD (Current)

Pushing to `main` triggers an automated deployment via GitHub Actions:

1. **CI** — Tests, RuboCop linting, Brakeman security scan, importmap audit
2. **Build** — Docker image is built and pushed to GitHub Container Registry (GHCR)
3. **Deploy** — The workflow SSHs into the DigitalOcean droplet, copies the compose file, pulls the new image, and runs database migrations

Production runs with Docker Compose: Caddy (reverse proxy with automatic HTTPS), PostgreSQL 17, and the Rails app.

## Troubleshooting

### `Gem::Ext::BuildError` during `bundle install`

PostgreSQL native extension build failure — install the dev headers:

```bash
# macOS
brew install postgresql@17

# Ubuntu/Debian
sudo apt install libpq-dev

# Fedora
sudo dnf install libpq-devel
```

### Tests fail with `KeyError: key not found: "REDIS_URL"`

This was fixed in the security hardening update. Make sure you're on the latest `main` branch. The fix changed `cable.yml` to use `ENV["REDIS_URL"]` (returns nil) instead of `ENV.fetch("REDIS_URL")` (raises in test/dev).

### Asset compilation issues

```bash
bin/rails assets:precompile
```

If styles look wrong in development, ensure Tailwind CSS is building:

```bash
bin/rails tailwindcss:build
```
