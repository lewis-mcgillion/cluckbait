# Cluckbait — Project Overview

A social platform for discovering and reviewing chicken shops across the UK. Browse an interactive map of shops, leave reviews with photos, react to other people's reviews, add shops to your wishlist, make friends, and message each other — all wrapped in a dark-themed UI built with Rails 8 and Hotwire.

## What's Inside

- **250 chicken shops** across 50 UK cities with real addresses and map coordinates
- **Interactive map** powered by Leaflet.js and OpenStreetMap
- **Reviews** with 1–5 star ratings, written text, photo uploads, and emoji reactions
- **Advanced search** — filter by name, city, rating range, review count, and photos
- **Wishlist** — save shops to try later and mark them as visited
- **Social features** — friend requests, activity feed, direct messaging with shop/review sharing
- **Real-time notifications** — alerts for friend requests, acceptances, and new messages via Turbo Streams
- **Admin panel** — user management, shop moderation, review moderation, audit logs
- **Localization** — 40+ languages
- **992 seed reviews** across 5 demo accounts so the app feels alive from the start

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8.1 (Ruby 3.4.1) |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS |
| Real-time | Turbo Streams + Action Cable (Solid Cable) |
| Database | PostgreSQL 17 |
| Auth | Devise (lockable, timeoutable) + OmniAuth (Google) |
| File Uploads | Active Storage |
| Maps | Leaflet.js + OpenStreetMap |
| Asset Pipeline | Propshaft + Importmap |
| Background Jobs | Solid Queue |
| Caching | Solid Cache |
| Monitoring | Sentry |
| Rate Limiting | Rack::Attack |
| Deployment | Docker + Caddy + GitHub Actions → DigitalOcean |

## Features

### Map & Discovery

The home page shows all 250 shops as markers on a full-width map. Click any marker to see the shop name, rating, and a link to its page. Use the search bar to filter by name or city, or click "Near Me" to find shops close to your location.

### Advanced Search & Filtering

The shops index page supports:

- **Search** by name and city
- **Filter** by minimum rating, rating range, minimum review count, and shops with photos
- **Sort** by highest rated, most popular, newest, or nearest to you (via browser geolocation)

### Reviews & Reactions

Each shop page shows a description, address, rating breakdown, location map, and all reviews. Signed-in users can leave a review with a star rating, written text, and photos. Reviews appear instantly via Turbo Streams. Other users can react with emoji (🔥 fire, 👍 thumbs up, 😍 heart eyes, 😂 laugh, 👏 helpful, 👎 not helpful) — reactions toggle on click.

### Wishlist

Save shops you want to try by adding them to your wishlist. Mark them as visited once you've been. Filter your wishlist by "want to try" or "visited" status.

### Friends & Activity Feed

Send and accept friend requests to build your network. Your activity feed shows what your friends have been up to — new reviews posted and new friendships formed.

### Messaging

Start conversations with friends and share shops or reviews directly in chat. Messages update in real time via Turbo Streams. Unread message counts appear in the navigation.

### Notifications

Get notified when someone sends you a friend request, accepts yours, or messages you. Mark individual notifications as read or clear them all at once.

### Profiles

Users can set a display name, write a bio, and upload an avatar. Profile pages show review history, average rating given, and wishlist items.

### Admin Panel

Admin users can manage the platform through a dedicated admin area:

- **Users** — view all users, ban/unban accounts
- **Shops** — edit or remove chicken shops
- **Reviews** — moderate and remove reviews
- **Audit Logs** — track all admin actions

### Localization

The app supports 40+ languages. Users can switch language via the locale selector, and the preference is stored in the session.

## Demo Accounts

All demo accounts use the password `password123`.

| Email | Display Name |
|---|---|
| cluckfan@example.com | CluckFan99 |
| wingking@example.com | WingKing |
| crispyqueen@example.com | CrispyQueen |
| poultrychef@example.com | PoultryCritic |
| spiceseeker@example.com | SpiceSeeker |

## Seed Data

All seed data lives in `db/seed_data/` as JSON files:

- `shops.json` — 250 chicken shops with addresses, coordinates, and descriptions
- `users.json` — 5 demo users
- `reviews.json` — 992 reviews linked by shop name/city and user email

Running `bin/rails db:seed` is idempotent — it uses `find_or_create_by!` so you can re-run safely.

## Testing

```bash
bin/rails test        # 341 tests, 620 assertions
bin/rubocop -f github # Style checks (rubocop-github)
```

Tests use Minitest with FactoryBot and run in parallel across all available CPU cores.

## Security

- **Rate limiting** — Rack::Attack throttles login attempts and API requests
- **Safe migrations** — strong_migrations catches unsafe migration patterns before production
- **Account lockout** — locks after 5 failed login attempts (auto-unlocks after 1 hour)
- **Session timeout** — sessions expire after 30 minutes of inactivity
- **Paranoid mode** — login and password reset forms don't reveal whether an account exists
- **Content Security Policy** — restricts scripts, styles, and connections to trusted origins
- **SQL injection protection** — all LIKE queries use `sanitize_sql_like`
- **Filtered logging** — passwords, tokens, and authorization headers are filtered from logs
- **Production headers** — `Permissions-Policy`, `X-Permitted-Cross-Domain-Policies`, HSTS via `force_ssl`
- **File upload validation** — content type and size checks on avatars (5 MB) and review photos (10 MB)

## License

This project is for educational and portfolio purposes.
