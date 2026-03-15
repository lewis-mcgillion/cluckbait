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

Uses [rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) — the Rails team's recommended style config.

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

## Deployment (Kamal)

The app is configured for deployment with [Kamal](https://kamal-deploy.org/):

```bash
kamal setup    # First deploy
kamal deploy   # Subsequent deploys
```

Kamal config lives in `config/deploy.yml`. Secrets are managed via `.kamal/secrets` (gitignored) which reads `config/master.key`.

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
