# 🍗 Cluckbait — Summary

**Cluckbait** is a full-stack Ruby on Rails application for discovering and reviewing chicken burgers from chicken shops across the UK. Users can explore shops on an interactive map, read and write reviews with ratings and photos, and personalise their profiles.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Backend** | Ruby on Rails 8.0.4 (Ruby 3.4.1) |
| **Frontend** | Hotwire (Turbo + Stimulus), custom CSS |
| **Database** | SQLite3 (development) |
| **Authentication** | Devise |
| **File Uploads** | Active Storage (local disk) |
| **Maps** | Leaflet.js + OpenStreetMap (no API key required) |
| **Asset Pipeline** | Propshaft + Importmap |
| **Fonts** | Google Fonts (Space Grotesk, Inter) |

---

## Features

### 🗺️ Interactive Map (Home Page)
- Full-screen Leaflet.js map centered on the UK showing all chicken shops as 🍗 markers
- Click a marker to see shop name, rating, and a link to the shop page
- **Live search**: type a shop name, city, or postcode to filter markers in real-time (400ms debounce)
- **Geolocation**: click "Near Me" to find shops close to your current location
- Top-rated shops and recent reviews displayed below the map

### 🏪 Chicken Shop Pages
- Hero section with shop name, address, overall rating, contact info, and website link
- **About** section with shop description
- **Rating breakdown** bar chart (5★ to 1★ distribution)
- **Location map** showing the shop's exact position
- **Review form** with interactive star rating (Stimulus-powered), title, body, and multi-photo upload
- **Reviews list** rendered in a Turbo Frame for seamless updates

### ⭐ Reviews System
- Users can rate shops 1–5 stars with an interactive star selector
- Write a title and detailed body text (up to 2,000 characters)
- Upload multiple photos per review via Active Storage
- One review per user per shop (enforced by model validation)
- **Turbo Streams**: new reviews appear instantly (prepended) without page reload; the form is replaced with a confirmation message
- Delete your own reviews with a confirmation dialog

### 👤 User Accounts & Profiles
- **Sign up** with email, password, and optional display name
- **Sign in / Sign out** with Devise
- **Password recovery** via email
- **Profile page** showing avatar, display name, bio, member since date, review count, and average rating given
- **Edit profile**: update display name, bio, and upload an avatar (with live preview via Stimulus)
- **Account settings**: change email, password, or delete account (danger zone)

### 🔍 Shop Discovery & Sorting
- **All Shops** page with search by name and filter by city
- **Sort by**: Name (A–Z), Highest Rated, Most Popular, Nearest to Me (uses browser geolocation)
- Results count and clear-filter button
- Responsive card grid with shop image, rating badge, city, and review count
- Distance display when sorting by proximity

---

## Architecture

### Data Models

```
User
├── id, email, encrypted_password (Devise)
├── display_name, bio
├── avatar (Active Storage)
└── has_many :reviews

ChickenShop
├── name, address, city, postcode
├── latitude, longitude
├── description, phone, website
├── image (Active Storage)
└── has_many :reviews

Review
├── user_id, chicken_shop_id
├── rating (1-5), title, body
├── photos (Active Storage, multiple)
└── belongs_to :user, :chicken_shop
```

### Controllers

| Controller | Purpose |
|-----------|---------|
| `HomeController` | Landing page with map, top shops, recent reviews |
| `ChickenShopsController` | Index (search/filter) and show pages |
| `ReviewsController` | Create and destroy reviews (Turbo Stream responses) |
| `ProfilesController` | Show, edit, and update user profiles |
| `Api::ShopsController` | JSON API for map marker data (supports search + geolocation) |
| `Users::RegistrationsController` | Extended Devise registration with display_name, bio, avatar |

### Stimulus Controllers (Hotwire)

| Controller | File | Purpose |
|-----------|------|---------|
| `map` | `map_controller.js` | Home page Leaflet map with search, markers, geolocation |
| `shop-map` | `shop_map_controller.js` | Individual shop location map |
| `star-rating` | `star_rating_controller.js` | Interactive 5-star rating selector |
| `flash` | `flash_controller.js` | Auto-dismissing flash notifications (5s) |
| `avatar-upload` | `avatar_upload_controller.js` | Live avatar preview on file select |
| `shop-sort` | `shop_sort_controller.js` | Sort controls + geolocation for distance sorting |

### Turbo Integration

- **Turbo Drive**: SPA-like page navigation across all pages
- **Turbo Frames**: Reviews list wrapped in `<turbo-frame id="reviews_list">` for scoped updates
- **Turbo Streams**: Review creation prepends the new review card and updates the form area; review deletion removes the card

---

## Design & Styling

- **Theme**: Dark mode with `#0f0f0f` background and `#ff6b35` (orange) accent colour
- **Typography**: Space Grotesk for headings, Inter for body text
- **Cards**: Rounded corners, subtle borders, hover lift effects
- **Responsive**: Mobile-first with breakpoint at 768px
- **Components**: ~660 lines of custom CSS covering navbar, hero, map, cards, forms, reviews, profiles, buttons, flash messages, footer, all Devise views, and Leaflet overrides
- **CSS Custom Properties**: Theming variables for easy customisation

---

## Seed Data

The app ships with comprehensive seed data across 50 UK cities:

- **250 real UK chicken shops** across London, Manchester, Birmingham, Glasgow, Edinburgh, Cardiff, Leeds, Newcastle, Brighton, Bristol, Liverpool, Sheffield, Nottingham, Leicester, Coventry, Bradford, Belfast, Stoke-on-Trent, Wolverhampton, Plymouth, Derby, Southampton, Northampton, Reading, Luton, Swindon, Southend, Bournemouth, Middlesbrough, Peterborough, Huddersfield, Oxford, Blackpool, Bolton, Ipswich, York, Cambridge, Dundee, Gloucester, Exeter, Aberdeen, Bath, Worcester, Swansea, Newport, Preston, Cheltenham, Milton Keynes, Warrington, and Doncaster — each with real addresses, coordinates, and descriptions
- **5 demo users** with themed display names and bios
- **992 reviews** with varied ratings (1–5), titles, and detailed body text
- All data is stored in `db/seed_data/*.json` and loaded via `db/seeds.rb`

### Demo Accounts

| Email | Password | Display Name |
|-------|----------|-------------|
| `cluckfan@example.com` | `password123` | CluckFan99 |
| `wingking@example.com` | `password123` | WingKing |
| `crispyqueen@example.com` | `password123` | CrispyQueen |
| `poultrychef@example.com` | `password123` | PoultryCritic |
| `spiceseeker@example.com` | `password123` | SpiceSeeker |

---

## Routes

```
Root:          GET  /                          → home#index
Sign in:       GET  /users/sign_in             → devise/sessions#new
Sign up:       GET  /users/sign_up             → devise/registrations#new
Shops:         GET  /chicken_shops             → chicken_shops#index
Shop detail:   GET  /chicken_shops/:id         → chicken_shops#show
Create review: POST /chicken_shops/:id/reviews → reviews#create
Delete review: DELETE /chicken_shops/:id/reviews/:id → reviews#destroy
Profile:       GET  /profiles/:id              → profiles#show
Edit profile:  GET  /profiles/:id/edit         → profiles#edit
Update profile: PATCH /profiles/:id            → profiles#update
API (map):     GET  /api/shops                 → api/shops#index
```

---

## Running the App

```bash
cd cluckbait

# One-command setup (installs deps, prepares DB, seeds data, starts server)
bin/setup

# Or step by step:
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server

# Visit http://localhost:3000
```

---

## Project Structure

```
cluckbait/
├── app/
│   ├── assets/stylesheets/application.css    # Complete custom CSS (~660 lines)
│   ├── controllers/                           # Rails controllers
│   │   ├── api/shops_controller.rb
│   │   ├── chicken_shops_controller.rb
│   │   ├── home_controller.rb
│   │   ├── profiles_controller.rb
│   │   ├── reviews_controller.rb
│   │   └── users/registrations_controller.rb
│   ├── javascript/controllers/                # Stimulus controllers
│   │   ├── application.js
│   │   ├── avatar_upload_controller.js
│   │   ├── flash_controller.js
│   │   ├── index.js
│   │   ├── map_controller.js
│   │   ├── shop_map_controller.js
│   │   ├── shop_sort_controller.js
│   │   └── star_rating_controller.js
│   ├── models/
│   │   ├── chicken_shop.rb
│   │   ├── review.rb
│   │   └── user.rb
│   └── views/
│       ├── chicken_shops/
│       │   ├── _card.html.erb
│       │   ├── index.html.erb
│       │   └── show.html.erb
│       ├── devise/
│       │   ├── passwords/
│       │   ├── registrations/
│       │   ├── sessions/
│       │   └── shared/
│       ├── home/index.html.erb
│       ├── layouts/application.html.erb
│       ├── profiles/
│       │   ├── edit.html.erb
│       │   └── show.html.erb
│       ├── reviews/
│       │   ├── _mini_card.html.erb
│       │   ├── _review_card.html.erb
│       │   ├── create.turbo_stream.erb
│       │   └── destroy.turbo_stream.erb
│       └── shared/
│           ├── _footer.html.erb
│           └── _navbar.html.erb
├── config/
│   ├── importmap.rb
│   └── routes.rb
├── db/
│   ├── seed_data/
│   │   ├── shops.json                         # 250 chicken shops
│   │   ├── users.json                         # 5 demo users
│   │   └── reviews.json                       # 992 reviews
│   └── seeds.rb                               # Loads seed_data/*.json
└── SUMMARY.md
```

---

*Built with Ruby on Rails 8, Hotwire (Turbo + Stimulus), Leaflet.js, Devise, and Active Storage.*
