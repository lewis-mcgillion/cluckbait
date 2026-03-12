# Cluckbait

A platform for discovering and reviewing chicken burgers from chicken shops across the UK. Search for shops near you on an interactive map, read reviews from other users, and share your own ratings and photos.

## What's Inside

- **250 chicken shops** across 50 UK cities, each with real addresses and map coordinates
- **Interactive map** powered by Leaflet.js and OpenStreetMap (no API key needed)
- **User accounts** with profiles, avatars, and bios
- **Review system** with 1-5 star ratings, written reviews, and photo uploads
- **Sorting** by name, highest rated, most popular, or nearest to you (via browser geolocation)
- **992 seed reviews** across 5 demo accounts so the app feels alive from the start

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8 |
| Frontend | Hotwire (Turbo + Stimulus), custom CSS |
| Database | SQLite3 |
| Auth | Devise |
| File Uploads | Active Storage |
| Maps | Leaflet.js + OpenStreetMap |
| Asset Pipeline | Propshaft + Importmap |

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

### Map (Home Page)
The home page shows all 250 shops as markers on a full-width map. Click any marker to see the shop name, rating, and a link to its page. Use the search bar to filter by name, city, or postcode, or click "Near Me" to find shops close to your location.

### Shop Pages
Each shop has its own page with a description, address, rating breakdown, location map, and a full list of reviews. Signed-in users can leave a review with a star rating, written text, and photos. Reviews appear instantly via Turbo Streams with no page reload.

### Profiles
Users can set a display name, write a bio, and upload an avatar. Profile pages show review history and average rating given.

### Sorting and Filtering
The shops index page lets you sort by:
- **Name** (A to Z)
- **Highest Rated** (average review score)
- **Most Popular** (number of reviews)
- **Nearest to Me** (uses browser geolocation)

You can also search by name and filter by city.

## Project Structure

```
cluckbait/
├── app/
│   ├── assets/stylesheets/    # Custom dark-themed CSS
│   ├── controllers/           # Rails controllers + API
│   ├── javascript/controllers/ # Stimulus controllers (map, sorting, ratings, etc.)
│   ├── models/                # User, ChickenShop, Review
│   └── views/                 # ERB templates with Turbo Frames/Streams
├── db/
│   ├── seed_data/             # JSON files with all shop, user, and review data
│   └── seeds.rb               # Loads seed_data/*.json into the database
└── bin/
    └── setup                  # One-command local setup script
```

## Seed Data

All seed data lives in `db/seed_data/` as JSON files:
- `shops.json` - 250 chicken shops with addresses, coordinates, and descriptions
- `users.json` - 5 demo users
- `reviews.json` - 992 reviews linked by shop name/city and user email

Running `bin/rails db:seed` is idempotent. It uses `find_or_create_by!` so you can re-run it safely without creating duplicates.

## License

This project is for educational and portfolio purposes.
