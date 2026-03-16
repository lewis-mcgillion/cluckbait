# Cluckbait

A social platform for discovering and reviewing chicken shops across the UK. Browse an interactive map of shops, leave reviews with photos, react to other people's reviews, add shops to your wishlist, make friends, and message each other — all in a dark-themed UI built with Rails 8 and Hotwire.

## What's Inside

- 🗺️ **Interactive map** of 250 chicken shops across 50 UK cities
- ⭐ **Reviews** with star ratings, photos, and emoji reactions
- 🔍 **Advanced search** — filter by rating, city, review count, and more
- 📋 **Wishlist** — save shops and track which ones you've visited
- 👥 **Social** — friend requests, activity feed, direct messaging
- 🔔 **Notifications** — friend requests, acceptances, and new messages
- 🌙 **Dark theme** with a custom design system

## Quick Start

```bash
git clone https://github.com/lewis-mcgillion/cluckbait.git
cd cluckbait
bin/setup
```

Then visit [http://localhost:3000](http://localhost:3000). Log in with any demo account (password: `password123`):

| Email | Display Name |
|---|---|
| cluckfan@example.com | CluckFan99 |
| wingking@example.com | WingKing |
| crispyqueen@example.com | CrispyQueen |
| poultrychef@example.com | PoultryCritic |
| spiceseeker@example.com | SpiceSeeker |

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8.1 |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS |
| Database | PostgreSQL (production), SQLite3 (development) |
| Auth | Devise + OmniAuth (Google) |
| Maps | Leaflet.js + OpenStreetMap |
| Deployment | Docker + GitHub Actions → DigitalOcean |

## Documentation

| Document | Description |
|---|---|
| **[Project Overview](docs/OVERVIEW.md)** | Features, tech stack, demo accounts, seed data, security |
| **[Local Setup Guide](docs/SETUP.md)** | Installation, environment variables, Docker, Kamal, troubleshooting |
| **[Architecture Deep Dive](docs/ARCHITECTURE.md)** | Data model, all 11 models, 14 controllers, 15 Stimulus controllers, routes, views, CSS, testing, security, deployment |

## Deployment

Pushing to `main` triggers an automated deployment via GitHub Actions:

1. **Build** — Docker image is built and pushed to GitHub Container Registry (GHCR)
2. **Deploy** — The workflow SSHs into the DigitalOcean droplet, copies the compose file, pulls the new image, and runs database migrations

## Testing

```bash
bin/rails test        # 341 tests, 620 assertions
bin/rubocop -f github # Style checks
```

## License

This project is for educational and portfolio purposes.
