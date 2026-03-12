# Cluckbait

A social platform for discovering and reviewing chicken shops across the UK. Browse an interactive map of shops, leave reviews with photos, react to other people's reviews, add shops to your wishlist, make friends, and message each other — all in a dark-themed UI built with Rails 8 and Hotwire.

## What's Inside

- **250 chicken shops** across 50 UK cities with real addresses and map coordinates
- **Interactive map** powered by Leaflet.js and OpenStreetMap
- **Reviews** with 1–5 star ratings, written text, photo uploads, and emoji reactions
- **Advanced search** — filter by name, city, rating range, review count, and photos
- **Wishlist** — save shops to try later and mark them as visited
- **Social features** — friend requests, activity feed, direct messaging
- **Notifications** — alerts for friend requests, acceptances, and new messages
- **992 seed reviews** across 5 demo accounts so the app feels alive from the start

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8.1 |
| Frontend | Hotwire (Turbo + Stimulus), Tailwind CSS |
| Database | SQLite3 |
| Auth | Devise (with lockable + timeoutable) |
| File Uploads | Active Storage |
| Maps | Leaflet.js + OpenStreetMap |
| Asset Pipeline | Propshaft + Importmap |
| Background Jobs | Solid Queue |
| Caching | Solid Cache |
| Deployment | Kamal + Thruster |

## Prerequisites

- **Ruby 3.1+** (developed with 3.4.1)
- **Bundler** (`gem install bundler`)
- **SQLite3**

## Getting Started

### Quick Setup

```bash
git clone https://github.com/lewis-mcgillion/cluckbait.git
cd cluckbait
bin/setup
```

This will install dependencies, create and seed the database (250 shops, 5 users, 992 reviews), and start the dev server.

### Manual Setup

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

## Demo Accounts

All demo accounts use the password `password123`.

| Email | Display Name |
|---|---|
| cluckfan@example.com | CluckFan99 |
| wingking@example.com | WingKing |
| crispyqueen@example.com | CrispyQueen |
| poultrychef@example.com | PoultryCritic |
| spiceseeker@example.com | SpiceSeeker |

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

## Project Structure

```
cluckbait/
├── app/
│   ├── assets/stylesheets/     # Tailwind CSS
│   ├── controllers/            # Rails controllers + API
│   │   └── api/                # JSON API for map integration
│   ├── javascript/controllers/ # 13 Stimulus controllers
│   ├── models/                 # 11 models (User, ChickenShop, Review, etc.)
│   └── views/                  # ERB templates with Turbo Frames/Streams
├── config/
│   └── initializers/           # Devise, CSP, filtered params
├── db/
│   ├── seed_data/              # JSON files with shop, user, and review data
│   └── seeds.rb                # Idempotent seed loader
├── test/
│   ├── controllers/            # Integration tests
│   ├── models/                 # Model unit tests
│   └── factories/              # FactoryBot factories
└── bin/
    └── setup                   # One-command local setup script
```

## Data Model

```
User ──< Review >── ChickenShop
 │         │
 │         └──< ReviewReaction
 │
 ├──< WishlistItem >── ChickenShop
 │
 ├──< Friendship >── User
 │
 ├──< Activity (polymorphic trackable)
 │
 ├──< Notification (polymorphic notifiable)
 │
 └──< Conversation ──< Message (polymorphic shareable)
                    └── ConversationRead
```

## Seed Data

All seed data lives in `db/seed_data/` as JSON files:
- `shops.json` — 250 chicken shops with addresses, coordinates, and descriptions
- `users.json` — 5 demo users
- `reviews.json` — 992 reviews linked by shop name/city and user email

Running `bin/rails db:seed` is idempotent — it uses `find_or_create_by!` so you can re-run safely.

## Testing

```bash
bin/rails test        # 341 tests, 620 assertions
bin/rubocop -f github # Style checks (rubocop-rails-omakase)
```

Tests use Minitest with FactoryBot and run in parallel across 8 processes.

## Security

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
