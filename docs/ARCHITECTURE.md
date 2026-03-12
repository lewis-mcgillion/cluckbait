# Architecture Deep Dive

A detailed walkthrough of Cluckbait's project structure, data model, request lifecycle, and every layer of the stack.

---

## Table of Contents

- [Directory Structure](#directory-structure)
- [Data Model](#data-model)
- [Database Schema](#database-schema)
- [Models](#models)
- [Controllers](#controllers)
- [Routes](#routes)
- [Views & Layouts](#views--layouts)
- [Stimulus Controllers (JavaScript)](#stimulus-controllers-javascript)
- [Asset Pipeline & Styling](#asset-pipeline--styling)
- [Authentication & Authorization](#authentication--authorization)
- [Real-Time Updates (Turbo)](#real-time-updates-turbo)
- [API Layer](#api-layer)
- [Background Jobs & Caching](#background-jobs--caching)
- [Testing Architecture](#testing-architecture)
- [Security Architecture](#security-architecture)
- [Deployment Architecture](#deployment-architecture)
- [Key Architectural Patterns](#key-architectural-patterns)

---

## Directory Structure

```
cluckbait/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.css          # 2000+ lines of dark theme CSS
│   ├── channels/
│   │   └── application_cable/           # Base Action Cable classes (unused)
│   ├── controllers/
│   │   ├── api/
│   │   │   └── shops_controller.rb      # JSON API for map markers
│   │   ├── users/
│   │   │   └── registrations_controller.rb  # Devise override
│   │   ├── activities_controller.rb
│   │   ├── application_controller.rb
│   │   ├── chicken_shops_controller.rb
│   │   ├── conversations_controller.rb
│   │   ├── friendships_controller.rb
│   │   ├── home_controller.rb
│   │   ├── messages_controller.rb
│   │   ├── notifications_controller.rb
│   │   ├── profiles_controller.rb
│   │   ├── review_reactions_controller.rb
│   │   ├── reviews_controller.rb
│   │   └── wishlist_items_controller.rb
│   ├── helpers/
│   │   └── application_helper.rb
│   ├── javascript/
│   │   ├── application.js               # Entry: imports Turbo + Stimulus
│   │   └── controllers/
│   │       ├── index.js                 # Auto-registers all controllers
│   │       ├── application.js           # Stimulus Application init
│   │       ├── avatar_upload_controller.js
│   │       ├── chat_scroll_controller.js
│   │       ├── flash_controller.js
│   │       ├── map_controller.js
│   │       ├── message_form_controller.js
│   │       ├── reaction_controller.js
│   │       ├── search_filter_controller.js
│   │       ├── share_panel_controller.js
│   │       ├── shop_map_controller.js
│   │       ├── shop_sort_controller.js
│   │       ├── star_rating_controller.js
│   │       └── wishlist_controller.js
│   ├── mailers/
│   │   └── application_mailer.rb        # Base mailer (Devise inherits)
│   ├── models/
│   │   ├── activity.rb
│   │   ├── application_record.rb
│   │   ├── chicken_shop.rb
│   │   ├── conversation.rb
│   │   ├── conversation_read.rb
│   │   ├── friendship.rb
│   │   ├── message.rb
│   │   ├── notification.rb
│   │   ├── review.rb
│   │   ├── review_reaction.rb
│   │   ├── user.rb
│   │   └── wishlist_item.rb
│   └── views/
│       ├── activities/
│       ├── chicken_shops/
│       ├── conversations/
│       ├── devise/
│       ├── friendships/
│       ├── home/
│       ├── layouts/
│       ├── messages/
│       ├── notifications/
│       ├── profiles/
│       ├── reviews/
│       ├── shared/
│       └── wishlist_items/
├── config/
│   ├── initializers/
│   │   ├── content_security_policy.rb
│   │   ├── devise.rb
│   │   └── filter_parameter_logging.rb
│   ├── environments/
│   │   ├── development.rb
│   │   ├── production.rb
│   │   └── test.rb
│   ├── cable.yml
│   ├── database.yml
│   ├── importmap.rb
│   ├── routes.rb
│   └── deploy.yml                       # Kamal deployment config
├── db/
│   ├── migrate/                         # All migration files
│   ├── seed_data/
│   │   ├── shops.json                   # 250 shops
│   │   ├── users.json                   # 5 demo accounts
│   │   └── reviews.json                 # 992 reviews
│   ├── schema.rb
│   └── seeds.rb                         # Idempotent seed loader
├── test/
│   ├── controllers/                     # Integration-style controller tests
│   ├── factories/                       # FactoryBot factories (10 files)
│   ├── integration/                     # Routing tests
│   ├── models/                          # Unit tests for all 11 models
│   └── test_helper.rb
├── .github/
│   └── CODEOWNERS                       # * @lewis-mcgillion
├── Dockerfile                           # Multi-stage production build
├── Gemfile
└── Rakefile
```

---

## Data Model

### Entity Relationship Diagram

```
┌──────────────────┐
│      User        │
│──────────────────│
│ email            │
│ encrypted_pass   │
│ display_name     │
│ bio              │
│ failed_attempts  │
│ locked_at        │
│ avatar (AS)      │
└──────┬───────────┘
       │
       ├──has_many──────────────────┐
       │                            ▼
       │                   ┌────────────────┐       ┌──────────────────┐
       │                   │    Review       │──────▶│   ChickenShop    │
       │                   │────────────────│       │──────────────────│
       │                   │ title          │       │ name             │
       │                   │ body           │       │ address          │
       │                   │ rating (1-5)   │       │ city / postcode  │
       │                   │ photos (AS)    │       │ lat / lng        │
       │                   └───────┬────────┘       │ description      │
       │                           │                │ phone / website  │
       │                           │ has_many       │ image (AS)       │
       │                           ▼                └──────────────────┘
       │                   ┌────────────────┐              ▲
       │                   │ ReviewReaction  │              │
       │                   │────────────────│              │
       │                   │ kind           │              │
       │                   │ (6 types)      │              │
       │                   └────────────────┘              │
       │                                                   │
       ├──has_many─────────────────────────────────────────┘
       │                   ┌────────────────┐
       │                   │  WishlistItem  │──────▶ ChickenShop
       │                   │────────────────│
       │                   │ visited        │
       │                   │ notes          │
       │                   └────────────────┘
       │
       ├──has_many (sent/received)
       │                   ┌────────────────┐
       │                   │   Friendship   │──────▶ User (friend)
       │                   │────────────────│
       │                   │ status         │
       │                   │ (pending/      │
       │                   │  accepted)     │
       │                   └────────────────┘
       │
       ├──has_many (sent/received)
       │                   ┌────────────────┐
       │                   │  Conversation  │──────▶ User (receiver)
       │                   │────────────────│
       │                   │                │
       │                   └───────┬────────┘
       │                           │
       │                           ├──has_many
       │                           │           ┌────────────────┐
       │                           │           │    Message     │
       │                           │           │────────────────│
       │                           │           │ body           │
       │                           │           │ shareable      │
       │                           │           │ (polymorphic)  │
       │                           │           └────────────────┘
       │                           │
       │                           └──has_many
       │                                       ┌──────────────────┐
       │                                       │ ConversationRead │
       │                                       │──────────────────│
       │                                       │ last_read_at     │
       │                                       └──────────────────┘
       │
       ├──has_many
       │                   ┌────────────────┐
       │                   │   Activity     │
       │                   │────────────────│
       │                   │ action         │
       │                   │ trackable      │
       │                   │ (polymorphic)  │
       │                   └────────────────┘
       │
       └──has_many
                           ┌────────────────┐
                           │  Notification  │
                           │────────────────│
                           │ action         │
                           │ actor_id       │
                           │ notifiable     │
                           │ (polymorphic)  │
                           │ read_at        │
                           └────────────────┘

(AS) = Active Storage attachment
```

### Polymorphic Relationships

The app uses three polymorphic associations:

| Association | On Model | Possible Types | Purpose |
|---|---|---|---|
| `trackable` | Activity | `Review`, `Friendship` | Tracks what triggered the activity |
| `shareable` | Message | `ChickenShop`, `Review` | Content shared in chat |
| `notifiable` | Notification | `Friendship`, `Conversation` | What the notification is about |

---

## Database Schema

### Users

```ruby
create_table "users" do |t|
  t.string   "email",                default: "", null: false  # Unique, indexed
  t.string   "encrypted_password",   default: "", null: false
  t.string   "display_name"                                     # Max 50 chars
  t.text     "bio"                                               # Max 500 chars
  t.integer  "failed_attempts",      default: 0,  null: false  # Lockable
  t.datetime "locked_at"                                         # Lockable
  t.string   "reset_password_token"                              # Indexed, unique
  t.datetime "reset_password_sent_at"
  t.datetime "remember_created_at"
  t.timestamps
end
# Indexes: email (unique), reset_password_token (unique)
# Active Storage: avatar (has_one_attached)
```

### Chicken Shops

```ruby
create_table "chicken_shops" do |t|
  t.string "name"                    # Required
  t.string "address"                 # Required
  t.string "city"                    # Required
  t.string "postcode"
  t.float  "latitude"               # Required, for map placement
  t.float  "longitude"              # Required, for map placement
  t.text   "description"
  t.string "phone"
  t.string "website"                # Validated as http(s):// URL
  t.timestamps
end
# Active Storage: image (has_one_attached)
```

### Reviews

```ruby
create_table "reviews" do |t|
  t.integer "user_id",         null: false    # FK → users
  t.integer "chicken_shop_id", null: false    # FK → chicken_shops
  t.integer "rating"                           # 1-5, required
  t.string  "title"                            # Required, max 100 chars
  t.text    "body"                             # Required, max 2000 chars
  t.timestamps
end
# Indexes: chicken_shop_id, user_id
# Unique constraint: one review per user per shop (model validation)
# Active Storage: photos (has_many_attached)
```

### Review Reactions

```ruby
create_table "review_reactions" do |t|
  t.integer "user_id",   null: false    # FK → users
  t.integer "review_id", null: false    # FK → reviews
  t.string  "kind",      null: false    # One of: fire, thumbs_up, heart_eyes,
  t.timestamps                          #         laugh, helpful, not_helpful
end
# Indexes: review_id, user_id
# Unique index: (user_id, review_id, kind) — one reaction type per user per review
```

### Friendships

```ruby
create_table "friendships" do |t|
  t.integer "user_id",   null: false    # FK → users (requester)
  t.integer "friend_id", null: false    # FK → users (recipient)
  t.integer "status",    default: 0, null: false  # Enum: 0=pending, 1=accepted
  t.timestamps
end
# Unique index: (user_id, friend_id)
# Indexes: friend_id, user_id
```

### Conversations

```ruby
create_table "conversations" do |t|
  t.integer "sender_id",   null: false   # FK → users
  t.integer "receiver_id", null: false   # FK → users
  t.timestamps
end
# Unique index: (sender_id, receiver_id) — one conversation per user pair
# Indexes: sender_id, receiver_id
```

### Messages

```ruby
create_table "messages" do |t|
  t.integer "user_id",         null: false    # FK → users
  t.integer "conversation_id", null: false    # FK → conversations
  t.text    "body"                             # Required if no shareable
  t.string  "shareable_type"                   # Polymorphic: ChickenShop or Review
  t.bigint  "shareable_id"
  t.timestamps
end
# Indexes: conversation_id, user_id, (shareable_type, shareable_id)
```

### Conversation Reads

```ruby
create_table "conversation_reads" do |t|
  t.integer  "user_id",         null: false   # FK → users
  t.integer  "conversation_id", null: false   # FK → conversations
  t.datetime "last_read_at",    null: false
  t.timestamps
end
# Unique index: (user_id, conversation_id)
```

### Wishlist Items

```ruby
create_table "wishlist_items" do |t|
  t.integer "user_id",         null: false    # FK → users
  t.integer "chicken_shop_id", null: false    # FK → chicken_shops
  t.boolean "visited",  default: false, null: false
  t.text    "notes"
  t.timestamps
end
# Unique index: (user_id, chicken_shop_id)
```

### Activities

```ruby
create_table "activities" do |t|
  t.integer  "user_id",        null: false    # FK → users
  t.string   "action",         null: false    # e.g. "posted_review", "became_friends"
  t.string   "trackable_type"                  # Polymorphic
  t.integer  "trackable_id"
  t.timestamps
end
# Indexes: (user_id, created_at), (trackable_type, trackable_id), user_id
```

### Notifications

```ruby
create_table "notifications" do |t|
  t.integer  "user_id",         null: false   # FK → users (recipient)
  t.integer  "actor_id"                        # FK → users (who triggered it)
  t.string   "action",          null: false   # friend_request | friend_accepted | new_message
  t.string   "notifiable_type"                 # Polymorphic
  t.integer  "notifiable_id"
  t.datetime "read_at"                         # NULL = unread
  t.timestamps
end
# Indexes: (user_id, read_at), (notifiable_type, notifiable_id), user_id
```

### Foreign Keys

All foreign key constraints are enforced at the database level:

```
activities           → users
conversation_reads   → users, conversations
conversations        → users (sender_id), users (receiver_id)
friendships          → users (user_id), users (friend_id)
messages             → users, conversations
notifications        → users (user_id), users (actor_id)
review_reactions     → users, reviews
reviews              → users, chicken_shops
wishlist_items       → users, chicken_shops
```

---

## Models

### User (`app/models/user.rb`)

The central model — everything connects back to User.

**Devise modules:** `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`, `lockable`, `timeoutable`

**Associations:**

```ruby
has_many :reviews, dependent: :destroy
has_many :review_reactions, dependent: :destroy
has_many :activities, dependent: :destroy
has_many :wishlist_items, dependent: :destroy
has_many :wishlisted_shops, through: :wishlist_items, source: :chicken_shop
has_many :notifications, dependent: :destroy
has_many :messages, dependent: :destroy
has_many :conversation_reads, dependent: :destroy
has_one_attached :avatar

# Bidirectional friendships
has_many :sent_friendships,     class_name: "Friendship", foreign_key: :user_id,   dependent: :destroy
has_many :received_friendships, class_name: "Friendship", foreign_key: :friend_id, dependent: :destroy

# Bidirectional conversations
has_many :sent_conversations,     class_name: "Conversation", foreign_key: :sender_id,   dependent: :destroy
has_many :received_conversations, class_name: "Conversation", foreign_key: :receiver_id, dependent: :destroy
```

**Validations:**

- `display_name` — max 50 characters
- `bio` — max 500 characters
- `avatar` — content type PNG/JPEG/GIF/WebP, max 5 MB

**Key methods:**

| Method | Returns | Description |
|---|---|---|
| `name` | String | `display_name` or email prefix |
| `friends` | `User::ActiveRecord_Relation` | All users with an accepted friendship |
| `pending_friend_requests` | `Friendship::ActiveRecord_Relation` | Incoming pending requests |
| `friendship_with(user)` | `Friendship` or `nil` | Finds friendship record in either direction |
| `friends_with?(user)` | Boolean | Accepted friendship exists? |
| `conversations` | `Conversation::ActiveRecord_Relation` | All conversations (sent or received) |
| `wishlisted?(shop)` | Boolean | Shop in user's wishlist? |
| `unread_notifications_count` | Integer | Count of notifications where `read_at IS NULL` |
| `unread_conversations_count` | Integer | Complex SQL: counts conversations with messages newer than `last_read_at` |

### ChickenShop (`app/models/chicken_shop.rb`)

The core content model — represents a physical chicken shop.

**Associations:**

```ruby
has_many :reviews, dependent: :destroy
has_many :wishlist_items, dependent: :destroy
has_one_attached :image
```

**Validations:** `name`, `address`, `city`, `latitude`, `longitude` all required. `website` validated as `https?://` URL.

**Search scopes** — all use `sanitize_sql_like` for SQL injection protection:

```ruby
scope :search_by_name, ->(q) { where("name LIKE ?", "%#{sanitize_sql_like(q)}%") }
scope :search_by_city, ->(c) { where("city LIKE ?", "%#{sanitize_sql_like(c)}%") }
```

**Filter scopes** — use LEFT JOIN on reviews with HAVING clauses:

```ruby
scope :with_min_rating, ->(rating) {
  left_joins(:reviews)
    .group(:id)
    .having("AVG(reviews.rating) >= ?", rating)
}

scope :in_rating_range, ->(min, max) {
  left_joins(:reviews)
    .group(:id)
    .having("AVG(reviews.rating) BETWEEN ? AND ?", min, max)
}

scope :with_min_reviews, ->(count) {
  left_joins(:reviews)
    .group(:id)
    .having("COUNT(reviews.id) >= ?", count)
}

scope :with_photos, -> {
  where("EXISTS (SELECT 1 FROM active_storage_attachments WHERE ...)")
}
```

**Sort scopes:**

```ruby
scope :by_highest_rated, -> { left_joins(:reviews).group(:id).order("AVG(reviews.rating) DESC") }
scope :by_most_popular,  -> { left_joins(:reviews).group(:id).order("COUNT(reviews.id) DESC") }
scope :by_newest,        -> { order(created_at: :desc) }
scope :by_distance_from, ->(lat, lng) { order(Arel.sql("(latitude - #{lat}) * ...")) }
```

**Distance calculation** — Haversine formula for accurate distance in km:

```ruby
def distance_from(lat, lng)
  rad = Math::PI / 180
  dlat = (latitude - lat) * rad
  dlng = (longitude - lng) * rad
  a = Math.sin(dlat / 2)**2 +
      Math.cos(lat * rad) * Math.cos(latitude * rad) * Math.sin(dlng / 2)**2
  6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
end
```

**Other methods:** `average_rating`, `reviews_count`, `full_address`, `rating_distribution` (returns `{1=>n, 2=>n, ...}`).

### Review (`app/models/review.rb`)

**Associations:**

```ruby
belongs_to :user
belongs_to :chicken_shop
has_many :reactions, class_name: "ReviewReaction", dependent: :destroy
has_many_attached :photos
```

**Validations:**

- `rating` — required, 1..5
- `title` — required, max 100 chars
- `body` — required, max 2000 chars
- `user_id` — unique per `chicken_shop_id` (one review per shop per user)
- `photos` — PNG/JPEG/GIF/WebP, max 10 MB each

**Scopes:** `recent`, `highest_rated`, `lowest_rated`, `by_most_helpful` (sorts by helpful minus not_helpful reaction counts via LEFT JOIN)

**Callbacks:**

```ruby
after_create :create_activity
# Creates an Activity record: action="posted_review", trackable=self
```

**Methods:** `reactions_summary` (grouped count by kind), `helpful_score` (helpful - not_helpful), `rating_label` (maps 1-5 → "Poor"…"Outstanding")

### Friendship (`app/models/friendship.rb`)

**Enum:** `status { pending: 0, accepted: 1 }`

**Validations:**

- Unique `(user_id, friend_id)` pair
- Custom `cannot_friend_self` — prevents `user_id == friend_id`

**Scopes:** `for_user(user)`, `accepted_for(user)`, `pending_for(user)`

**Callbacks — creates notifications and activities on state changes:**

```ruby
after_create  :notify_friend_request     # If pending → notification to friend
after_update  :create_accepted_activity   # If accepted → Activity for both users
after_update  :notify_friend_accepted     # If accepted → notification to requester
```

### Conversation (`app/models/conversation.rb`)

**Validations:**

- Unique `(sender_id, receiver_id)` — one conversation per user pair
- Custom `must_be_friends` — both users must have an accepted friendship

**Scopes:** `for_user(user)`, `between(user1, user2)`, `ordered` (by `updated_at DESC`)

### Message (`app/models/message.rb`)

**Constants:** `ALLOWED_SHAREABLE_TYPES = %w[ChickenShop Review]`

The `shareable` polymorphic association allows sharing shops or reviews in chat. The shareable type is validated server-side against the whitelist.

**Validations:**

- `body` — required when no shareable; max 2000 chars when shareable present
- `shareable_type` — must be in `ALLOWED_SHAREABLE_TYPES` (or nil)
- Custom `user_is_participant` — sender must be part of the conversation

**Callbacks:**

```ruby
after_create :notify_recipient
# Creates a Notification with action="new_message" for the other participant
```

**Note:** `belongs_to :conversation, touch: true` — creating a message updates the conversation's `updated_at`, which keeps conversations ordered by most recent activity.

### Notification (`app/models/notification.rb`)

**Constants:** `ACTIONS = %w[friend_request friend_accepted new_message]`

**Scopes:** `unread` (`read_at IS NULL`), `read`, `recent_first`

**Methods:**

- `mark_as_read!` — sets `read_at` to `Time.current`
- `icon` — returns emoji per action: 👋 (friend_request), ✅ (friend_accepted), 💬 (new_message)
- `message_text` — human-readable string, e.g. "sent you a friend request"
- `target_path` — returns the appropriate URL path based on action type

### ReviewReaction (`app/models/review_reaction.rb`)

**Constants:** `KINDS = %w[fire thumbs_up heart_eyes laugh helpful not_helpful]`

**Uniqueness:** One reaction of each kind per user per review. Users can have multiple different reaction types on the same review.

### WishlistItem (`app/models/wishlist_item.rb`)

**Scopes:** `want_to_try` (visited=false), `visited` (visited=true), `recent`

**Uniqueness:** One wishlist entry per user per shop.

### Activity (`app/models/activity.rb`)

**Scopes:** `recent`, `for_users(user_ids)` — used to build the activity feed showing only friends' activities.

### ConversationRead (`app/models/conversation_read.rb`)

Tracks when a user last read a conversation, used to calculate unread message counts.

**Class method:**

```ruby
def self.mark_read!(user, conversation)
  record = find_or_initialize_by(user: user, conversation: conversation)
  record.update!(last_read_at: Time.current)
end
```

---

## Controllers

### Request Flow

```
Browser Request
    │
    ▼
ApplicationController
    │ ├── allow_browser (versions: :modern)
    │ └── rescue_from ActiveRecord::RecordNotFound → 404
    │
    ▼
Route Match (config/routes.rb)
    │
    ▼
Controller Action
    │ ├── before_action :authenticate_user! (Devise)
    │ ├── before_action :set_resource
    │ └── Authorization check (ownership via current_user.association.find)
    │
    ▼
Response
    ├── HTML (default)
    ├── Turbo Stream (for AJAX updates)
    └── JSON (API only)
```

### HomeController

| Action | Route | Description |
|---|---|---|
| `index` | `GET /` | Landing page — loads all shops for map, 6 recent reviews, 6 top-rated shops |

### ChickenShopsController

| Action | Route | Description |
|---|---|---|
| `index` | `GET /chicken_shops` | Search/filter/sort shops with chained scopes |
| `show` | `GET /chicken_shops/:id` | Shop details, reviews (sortable), review form, wishlist button |

The `index` action chains scopes dynamically based on params:

```ruby
@shops = ChickenShop.all
@shops = @shops.search_by_name(params[:search])   if params[:search].present?
@shops = @shops.search_by_city(params[:city])      if params[:city].present?
@shops = @shops.in_rating_range(min, max)          if params[:rating_min] && params[:rating_max]
@shops = @shops.with_min_rating(params[:rating])   if params[:rating].present?
@shops = @shops.with_min_reviews(params[:reviews])  if params[:reviews].present?
@shops = @shops.with_photos                         if params[:has_photos] == "true"
# Then sort...
```

### ReviewsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `create` | `POST /chicken_shops/:id/reviews` | ✅ | Build review, respond with Turbo Stream or HTML |
| `destroy` | `DELETE /chicken_shops/:id/reviews/:id` | ✅ | Owner-only via `current_user.reviews.find` |

### ReviewReactionsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `create` | `POST /reviews/:id/reactions` | ✅ | Toggle: finds existing → destroy, or create new |

The toggle pattern avoids separate create/destroy routes — clicking the same reaction twice removes it:

```ruby
existing = @review.reactions.find_by(user: current_user, kind: params[:kind])
if existing
  existing.destroy
else
  @review.reactions.create!(user: current_user, kind: params[:kind])
end
```

### ProfilesController

| Action | Route | Auth | Description |
|---|---|---|---|
| `show` | `GET /profiles/:id` | No | Public — reviews + wishlist |
| `edit` | `GET /profiles/:id/edit` | ✅ | Own profile only |
| `update` | `PATCH /profiles/:id` | ✅ | Own profile only |

Authorization: redirects with alert if `current_user.id != params[:id].to_i`.

### FriendshipsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `index` | `GET /friendships` | ✅ | Lists friends, pending requests, sent requests |
| `create` | `POST /friendships` | ✅ | Creates pending request; handles `RecordNotUnique` race |
| `update` | `PATCH /friendships/:id` | ✅ | Accepts request (only if current user is the recipient) |
| `destroy` | `DELETE /friendships/:id` | ✅ | Removes friendship + deletes conversations between users |

### ConversationsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `index` | `GET /conversations` | ✅ | All conversations, ordered by most recent |
| `show` | `GET /conversations/:id` | ✅ | Chat view; marks conversation as read |
| `create` | `POST /conversations` | ✅ | Find-or-create with friend; handles race condition |

### MessagesController

| Action | Route | Auth | Description |
|---|---|---|---|
| `create` | `POST /conversations/:id/messages` | ✅ | Validates shareable exists before assigning |

Shareable validation (security fix):

```ruby
if params[:shareable_type].present? && params[:shareable_id].present?
  if Message::ALLOWED_SHAREABLE_TYPES.include?(params[:shareable_type])
    shareable = params[:shareable_type].constantize.find_by(id: params[:shareable_id])
    @message.shareable = shareable if shareable
  end
end
```

### WishlistItemsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `index` | `GET /wishlist_items` | ✅ | Filter: all / want_to_try / visited |
| `create` | `POST /wishlist_items` | ✅ | Creates with `visited: false` explicitly |
| `update` | `PATCH /wishlist_items/:id` | ✅ | Toggles visited flag |
| `destroy` | `DELETE /wishlist_items/:id` | ✅ | Removes from wishlist |

### ActivitiesController

| Action | Route | Auth | Description |
|---|---|---|---|
| `index` | `GET /activities` | ✅ | Friends' activities, 20 per page, eager loaded |

### NotificationsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `index` | `GET /notifications` | ✅ | 50 most recent, eager loaded |
| `mark_as_read` | `PATCH /notifications/:id/mark_as_read` | ✅ | Turbo Stream response |
| `mark_all_as_read` | `POST /notifications/mark_all_as_read` | ✅ | Turbo Stream response |

### Api::ShopsController

| Action | Route | Auth | Description |
|---|---|---|---|
| `index` | `GET /api/shops` | No | JSON endpoint for map; no CSRF (`null_session`) |

**Features:**

- Optional search (LIKE on name/city/postcode with `sanitize_sql_like`)
- Geolocation bounding box filter (`lat ±0.5, lng ±0.8` — roughly 30 miles)
- Validates lat/lng ranges before use
- Returns JSON: `id, name, address, city, postcode, lat, lng, average_rating, reviews_count, url`

### Users::RegistrationsController (Devise Override)

Overrides `update_resource` to call `update_without_password` — allows profile edits without re-entering the current password. Also permits `display_name`, `bio`, `avatar` in sign-up and account update params.

---

## Routes

```
Root:
  GET  /                                    → home#index

Devise (authentication):
  GET  /users/sign_in                       → devise/sessions#new
  POST /users/sign_in                       → devise/sessions#create
  DELETE /users/sign_out                    → devise/sessions#destroy
  GET  /users/sign_up                       → users/registrations#new
  POST /users                               → users/registrations#create
  GET  /users/edit                           → users/registrations#edit
  PATCH /users                              → users/registrations#update
  GET  /users/password/new                  → devise/passwords#new
  POST /users/password                      → devise/passwords#create
  GET  /users/password/edit                 → devise/passwords#edit
  PATCH /users/password                     → devise/passwords#update

Chicken Shops:
  GET  /chicken_shops                       → chicken_shops#index
  GET  /chicken_shops/:id                   → chicken_shops#show

Reviews (nested under shops):
  POST   /chicken_shops/:chicken_shop_id/reviews       → reviews#create
  DELETE /chicken_shops/:chicken_shop_id/reviews/:id   → reviews#destroy

Reactions (nested under reviews):
  POST /reviews/:review_id/reactions        → review_reactions#create

Profiles:
  GET   /profiles/:id                       → profiles#show
  GET   /profiles/:id/edit                  → profiles#edit
  PATCH /profiles/:id                       → profiles#update

Wishlist:
  GET    /wishlist_items                    → wishlist_items#index
  POST   /wishlist_items                    → wishlist_items#create
  PATCH  /wishlist_items/:id               → wishlist_items#update
  DELETE /wishlist_items/:id               → wishlist_items#destroy

Social:
  GET    /friendships                       → friendships#index
  POST   /friendships                       → friendships#create
  PATCH  /friendships/:id                   → friendships#update
  DELETE /friendships/:id                   → friendships#destroy
  GET    /activities                         → activities#index

Messaging:
  GET  /conversations                       → conversations#index
  GET  /conversations/:id                   → conversations#show
  POST /conversations                       → conversations#create
  POST /conversations/:conversation_id/messages → messages#create

Notifications:
  GET   /notifications                      → notifications#index
  PATCH /notifications/:id/mark_as_read     → notifications#mark_as_read
  POST  /notifications/mark_all_as_read     → notifications#mark_all_as_read

API:
  GET  /api/shops                           → api/shops#index (JSON)

Health:
  GET  /up                                  → rails/health#show
```

---

## Views & Layouts

### Application Layout (`app/views/layouts/application.html.erb`)

The main layout includes:

- `<head>` with CSP nonce meta tags, Turbo meta tags, importmap includes
- Navbar partial (`shared/_navbar`) — logo, navigation links, user menu with notification/message badges
- Flash messages with Stimulus `flash` controller (auto-dismiss after 5s)
- Main content via `yield`
- Footer partial (`shared/_footer`)

### View Directory Structure

```
views/
├── layouts/
│   ├── application.html.erb        # Main layout
│   └── mailer.html.erb             # Email layout
├── home/
│   └── index.html.erb              # Hero section, map, top shops grid, recent reviews
├── chicken_shops/
│   ├── index.html.erb              # Search bar, filter panel, shop cards grid
│   ├── show.html.erb               # Shop details, map, rating breakdown, review list
│   └── _card.html.erb              # Shop card (used in index + home)
├── reviews/
│   ├── _review_card.html.erb       # Full review with reactions, photos, user link
│   ├── _mini_card.html.erb         # Compact review for home page
│   ├── _reaction_bar.html.erb      # 6 emoji reaction buttons with counts
│   ├── create.turbo_stream.erb     # Appends new review via Turbo
│   └── destroy.turbo_stream.erb    # Removes review via Turbo
├── conversations/
│   ├── index.html.erb              # Conversation list with unread indicators
│   └── show.html.erb               # Chat UI with share panel
├── messages/
│   └── _message.html.erb           # Single message bubble with optional shareable
├── wishlist_items/
│   ├── index.html.erb              # Filter tabs (all/want to try/visited)
│   ├── _wishlist_button.html.erb   # Add to wishlist button (shop page)
│   ├── _card_button.html.erb       # Wishlist button variant
│   ├── create.turbo_stream.erb
│   ├── update.turbo_stream.erb
│   └── destroy.turbo_stream.erb
├── friendships/
│   └── index.html.erb              # Three sections: friends, pending, sent
├── profiles/
│   ├── show.html.erb               # User avatar, bio, reviews, wishlist
│   └── edit.html.erb               # Edit form with avatar upload preview
├── activities/
│   └── index.html.erb              # Activity feed with pagination (20/page)
├── notifications/
│   ├── index.html.erb              # Notification list with mark-all-read
│   ├── _notification.html.erb      # Single notification with icon + link
│   ├── mark_as_read.turbo_stream.erb
│   └── mark_all_as_read.turbo_stream.erb
├── shared/
│   ├── _navbar.html.erb            # Header: logo, links, badges, user dropdown
│   └── _footer.html.erb            # Footer
└── devise/                         # Standard Devise views (login, register, etc.)
```

### Turbo Frame & Stream Patterns

**Turbo Frames** — used for scoped page updates:

- Review form wraps in `turbo_frame_tag` so form submission replaces only the frame
- Links that should navigate the full page use `data: { turbo_frame: "_top" }` to break out of the frame

**Turbo Streams** — used for real-time DOM manipulation after form submissions:

- `reviews/create.turbo_stream.erb` → appends new review card to the review list
- `reviews/destroy.turbo_stream.erb` → removes the review card
- `wishlist_items/*.turbo_stream.erb` → replaces wishlist button state
- `notifications/mark_as_read.turbo_stream.erb` → replaces notification card
- `notifications/mark_all_as_read.turbo_stream.erb` → replaces entire notification list

---

## Stimulus Controllers (JavaScript)

All controllers live in `app/javascript/controllers/` and are auto-registered via `index.js`.

### map_controller.js — Home Page Map

The main interactive map on the home page.

**Values:** `shops` (Array)

**Behavior:**

1. Initializes a Leaflet map centered on the UK (53.5°N, 2.5°W, zoom 6)
2. Uses OpenStreetMap tiles (free, no API key)
3. Places 🍗 emoji markers for each shop
4. Marker popups show: shop name, address, star rating, review count, link to shop page
5. Fetches shop data from `/api/shops` with optional search/location params
6. "Near Me" button uses the Geolocation API to center the map and load nearby shops
7. Search input has 400ms debounce

### shop_map_controller.js — Individual Shop Map

A smaller, focused map on the shop detail page.

**Values:** `lat`, `lng`, `name` (all Numbers/String)

Shows a single marker at the shop's coordinates, zoom level 15.

### search_filter_controller.js — Advanced Search Panel

**Targets:** `form`, `filtersForm`, `filtersPanel`, `toggleBtn`, `ratingMin`, `ratingMax`, `sortField`

- Toggle button shows/hides the advanced filters panel
- Clicking a rating button sets the filter value and auto-submits
- All filter changes have 400ms debounce before submitting
- Submits the form via `requestSubmit()` for Turbo compatibility

### shop_sort_controller.js — Sort Controls

**Targets:** `form`, `sortField`, `latField`, `lngField`, `distanceBtn`

- Sort buttons set the sort field and submit
- "Sort by Distance" uses the Geolocation API:
  - Requests high accuracy, 10s timeout
  - Populates hidden lat/lng fields, sets sort to "distance"
  - Handles permission denied, timeout, and unavailable errors with user messages

### star_rating_controller.js — Review Form Stars

**Targets:** `star` (multiple), `input`

- Click to select rating (1-5 stars)
- Hover preview shows potential rating
- Updates a hidden input field for form submission
- Visual: adds/removes `active` CSS class

### reaction_controller.js — Review Reaction Buttons

**Targets:** `button`, `count`

- Toggle `reaction-btn--active` class on click
- Animates the count change

### chat_scroll_controller.js — Message Auto-Scroll

Uses a `MutationObserver` on the message container to auto-scroll to the bottom whenever new messages appear (via Turbo Stream). Scrolls to bottom on initial connect.

### wishlist_controller.js — Wishlist Button

**Targets:** `button`

Adds `wishlist-loading` class and disables the button while the request is in flight.

### avatar_upload_controller.js — Profile Avatar

**Targets:** `preview`, `input`

- Click avatar to trigger hidden file input
- Uses `FileReader` to show a live preview of the selected image before upload

### share_panel_controller.js — Chat Share Panel

**Targets:** `content`, `shopsPane`, `reviewsPane`, `shopSearch`, `shopResults`

- Tabbed panel: switch between Shops and Reviews panes
- Shops tab has live search (fetches `/api/shops?search=...`)
- Renders up to 10 results with 🍗 icon, name, city, rating
- Selecting an item calls the `message_form` controller's `setShare` method

### message_form_controller.js — Chat Message Form

**Targets:** `shareableType`, `shareableId`, `sharePreview`, `sharePreviewText`, `input`

Manages the share state in the message form — sets hidden fields for the shareable type/ID and shows a preview of what's being shared.

### flash_controller.js — Flash Message Dismiss

- Auto-dismisses flash messages after 5 seconds with a fade animation
- Click to dismiss immediately
- Cleans up timeout on disconnect

---

## Asset Pipeline & Styling

### Pipeline

The app uses **Propshaft** (Rails 8 default) with **Importmap** for JavaScript — no Node.js, no Webpack, no esbuild.

```
config/importmap.rb
├── pin "application"                    → app/javascript/application.js
├── pin "@hotwired/turbo-rails"          → Turbo (via importmap)
├── pin "@hotwired/stimulus"             → Stimulus (via importmap)
├── pin "@hotwired/stimulus-loading"     → Stimulus auto-loading
└── pin_all_from "app/javascript/controllers"  → All Stimulus controllers
```

Leaflet.js is loaded from unpkg CDN (not bundled):

```html
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
```

### CSS Architecture

`app/assets/stylesheets/application.css` — a single 2000+ line file containing the entire dark theme.

**Design tokens (CSS custom properties):**

```css
:root {
  --bg-primary:   #0f0f0f;
  --bg-secondary: #1a1a1a;
  --bg-card:      #222222;
  --accent:       #ff6b35;    /* Orange — primary action colour */
  --accent-hover: #ff8c5a;
  --success:      #4ecb71;
  --danger:       #ef4444;
  --text-primary: #f5f5f5;
  --text-secondary: #a0a0a0;
  --border:       #333333;
  --border-radius:    12px;
  --border-radius-sm: 8px;
  --border-radius-lg: 16px;
}
```

**Typography:** Space Grotesk (headings/display) + Inter (body text) from Google Fonts.

**Component library:** Buttons (primary, outline, danger), cards, forms, modals, grid layouts, map containers, reaction buttons, notification badges, chat bubbles, star ratings.

**Responsive:** Mobile-first with media queries. The map, shop grid, and filter panels adapt to screen size.

---

## Authentication & Authorization

### Authentication (Devise)

Devise handles all user authentication with the following modules:

| Module | Purpose |
|---|---|
| `database_authenticatable` | Email + password login |
| `registerable` | Self-service sign-up |
| `recoverable` | Password reset via email |
| `rememberable` | "Remember me" cookie |
| `validatable` | Email format + password length (min 10 chars) |
| `lockable` | Locks after 5 failed attempts, auto-unlocks after 1 hour |
| `timeoutable` | Session expires after 30 minutes of inactivity |

**Paranoid mode** is enabled — login and password reset pages never reveal whether an email exists.

### Authorization

There is no role-based system (no admin role). Authorization is enforced via ownership patterns:

| Pattern | Used In | How It Works |
|---|---|---|
| `current_user.association.find(id)` | Reviews, Wishlist, Notifications | Scopes query to current user — raises `RecordNotFound` if not owner |
| Explicit ID check | Profiles | `redirect unless current_user.id == params[:id].to_i` |
| Friendship validation | Conversations | Model validates `must_be_friends` |
| Participant check | Messages | Model validates `user_is_participant` |

### Session Security

- CSRF protection via `csrf_meta_tags` and `protect_from_forgery` (except API)
- API controller uses `protect_from_forgery with: :null_session` (stateless)
- Cookies are secure + httponly in production (Rails default with `force_ssl`)

---

## Real-Time Updates (Turbo)

The app uses **Turbo Drive** (page navigation) and **Turbo Streams** (partial page updates) but **not Action Cable** for WebSocket-based real-time.

### How Turbo Streams Work Here

When a form submits with `format.turbo_stream`, the server responds with a Turbo Stream document that instructs the browser to modify the DOM:

```erb
<%# reviews/create.turbo_stream.erb %>
<%= turbo_stream.prepend "reviews" do %>
  <%= render partial: "reviews/review_card", locals: { review: @review } %>
<% end %>
```

This prepends the new review card to the `#reviews` container without a full page reload.

### Where Turbo Streams Are Used

| Feature | Action | Stream Operation |
|---|---|---|
| Reviews | Create | Prepend to review list |
| Reviews | Destroy | Remove from review list |
| Reactions | Toggle | Replace reaction bar |
| Wishlist | Add/Remove/Toggle | Replace wishlist button |
| Notifications | Mark read | Replace notification card |
| Notifications | Mark all read | Replace notification list |

### Turbo Frame Gotcha

Links inside a `turbo_frame_tag` try to find a matching frame in the response. User profile links in review cards needed `data: { turbo_frame: "_top" }` to break out and navigate the full page — otherwise they showed "Content missing".

---

## API Layer

### `GET /api/shops`

The only API endpoint. Returns JSON for the Leaflet map.

**No authentication required.** Uses `protect_from_forgery with: :null_session` since it's called from JavaScript `fetch()`.

**Parameters:**

| Param | Type | Description |
|---|---|---|
| `search` | String | LIKE search on name, city, or postcode |
| `lat` | Float | User latitude (for nearby search) |
| `lng` | Float | User longitude (for nearby search) |

When `lat`/`lng` are provided, the API filters to a bounding box of `±0.5° lat` and `±0.8° lng` (approximately 30 miles).

**Response shape:**

```json
[
  {
    "id": 1,
    "name": "Morley's",
    "address": "123 High Street, London SE1 1AA",
    "city": "London",
    "postcode": "SE1 1AA",
    "lat": 51.5074,
    "lng": -0.1278,
    "average_rating": 4.2,
    "reviews_count": 15,
    "url": "/chicken_shops/1"
  }
]
```

---

## Background Jobs & Caching

### Solid Queue

The app includes `solid_queue` for database-backed background jobs. The queue adapter is configured but no custom jobs are currently defined — all operations are synchronous (notifications, activities, etc. are created inline in callbacks).

### Solid Cache

`solid_cache` provides database-backed caching. Enabled in production via `config.cache_store`. No fragment caching is currently implemented in views.

### Solid Cable

`solid_cable` provides database-backed Action Cable (no Redis needed in development). The `cable.yml` config falls back safely when `REDIS_URL` is not set:

```yaml
production:
  adapter: <%= ENV["REDIS_URL"].present? ? "redis" : "solid_cable" %>
  url: <%= ENV["REDIS_URL"] %>
```

---

## Testing Architecture

### Framework

- **Minitest** — Rails default test framework
- **FactoryBot** — test data factories (replaces fixtures)
- **Parallelization** — tests run across all CPU cores (`parallelize(workers: :number_of_processors)`)

### Test Organization

```
test/
├── test_helper.rb                  # FactoryBot integration, Devise helpers, parallel setup
├── controllers/                    # Integration-style tests (simulate HTTP requests)
│   ├── activities_controller_test.rb
│   ├── application_controller_test.rb
│   ├── chicken_shops_controller_test.rb
│   ├── conversations_controller_test.rb
│   ├── friendships_controller_test.rb
│   ├── home_controller_test.rb
│   ├── messages_controller_test.rb
│   ├── notifications_controller_test.rb
│   ├── profiles_controller_test.rb
│   ├── review_reactions_controller_test.rb
│   ├── reviews_controller_test.rb
│   ├── users/
│   │   └── registrations_controller_test.rb
│   └── wishlist_items_controller_test.rb
├── factories/                      # FactoryBot factory definitions
│   ├── activities.rb
│   ├── chicken_shops.rb
│   ├── conversations.rb
│   ├── friendships.rb
│   ├── messages.rb
│   ├── notifications.rb
│   ├── review_reactions.rb
│   ├── reviews.rb
│   ├── users.rb
│   └── wishlist_items.rb
├── integration/
│   └── routing_test.rb             # Route existence tests
├── models/                         # Unit tests for all models
│   ├── activity_test.rb
│   ├── chicken_shop_test.rb
│   ├── conversation_read_test.rb
│   ├── conversation_test.rb
│   ├── friendship_test.rb
│   ├── message_test.rb
│   ├── notification_test.rb
│   ├── review_reaction_test.rb
│   ├── review_test.rb
│   ├── user_test.rb
│   └── wishlist_item_test.rb
└── system/
    └── (system tests placeholder)
```

### Test Helper Setup

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods   # Use build(), create() directly
  parallelize(workers: :number_of_processors)
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # sign_in/sign_out helpers
end
```

### Factory Notes

- User factory password is `"password123"` (11 chars) — must stay in sync with the 10-char minimum set in Devise config
- Factories use sequences for unique emails: `sequence(:email) { |n| "user#{n}@example.com" }`
- Traits: `:without_display_name`, `:with_long_display_name`, `:with_long_bio`

---

## Security Architecture

### Defense in Depth

```
                            ┌─────────────────────────────┐
                            │      Production Proxy       │
                            │  (Thruster: HTTP cache +    │
                            │   compression + X-headers)  │
                            └─────────────┬───────────────┘
                                          │
                            ┌─────────────▼───────────────┐
                            │        Rails App            │
                            │                             │
                            │  ┌── force_ssl ──────────┐  │
                            │  │  HSTS, secure cookies  │  │
                            │  └────────────────────────┘  │
                            │                             │
                            │  ┌── CSP ────────────────┐  │
                            │  │  Script/style/connect  │  │
                            │  │  restrictions + nonces │  │
                            │  └────────────────────────┘  │
                            │                             │
                            │  ┌── CSRF ───────────────┐  │
                            │  │  protect_from_forgery  │  │
                            │  │  (null_session for API)│  │
                            │  └────────────────────────┘  │
                            │                             │
                            │  ┌── Devise ─────────────┐  │
                            │  │  Lockable (5 attempts) │  │
                            │  │  Timeoutable (30 min)  │  │
                            │  │  Paranoid mode         │  │
                            │  │  Password min 10 chars │  │
                            │  │  bcrypt hashing        │  │
                            │  └────────────────────────┘  │
                            │                             │
                            │  ┌── Input Validation ───┐  │
                            │  │  sanitize_sql_like     │  │
                            │  │  Strong Parameters     │  │
                            │  │  Model validations     │  │
                            │  │  Upload type/size      │  │
                            │  └────────────────────────┘  │
                            │                             │
                            │  ┌── Output ─────────────┐  │
                            │  │  ERB auto-escaping     │  │
                            │  │  Filtered params log   │  │
                            │  └────────────────────────┘  │
                            └─────────────────────────────┘
```

### Content Security Policy

Configured in `config/initializers/content_security_policy.rb`:

```ruby
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, "https://*.tile.openstreetmap.org"
    policy.object_src  :none
    policy.script_src  :self, "https://unpkg.com"     # Leaflet CDN
    policy.style_src   :self, "https://unpkg.com", "https://fonts.googleapis.com"
    policy.connect_src :self
  end
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
```

### Production Headers

Additional security headers set in `config/environments/production.rb`:

```ruby
config.action_dispatch.default_headers.merge!(
  "Permissions-Policy" => "camera=(), microphone=(), geolocation=(self)",
  "X-Permitted-Cross-Domain-Policies" => "none"
)
```

Rails defaults also include: `X-Frame-Options: SAMEORIGIN`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`.

### Filtered Parameters

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp,
  :ssn, :cvv, :cvc, :authorization
]
```

---

## Deployment Architecture

### Docker Build (Multi-Stage)

```dockerfile
# Stage 1: Base (runtime dependencies)
FROM ruby:3.4.1-slim AS base
RUN apt-get install -y libsqlite3-0 curl

# Stage 2: Build (compile gems, assets)
FROM base AS build
RUN bundle install --without development test
RUN bin/rails assets:precompile
RUN bundle exec bootsnap precompile

# Stage 3: Final (minimal production image)
FROM base
COPY --from=build /rails /rails
USER rails:rails
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
```

### Kamal Deployment

[Kamal](https://kamal-deploy.org/) orchestrates Docker-based deployments:

1. Builds the Docker image
2. Pushes to a container registry
3. Deploys to target servers with zero-downtime rolling updates
4. Manages secrets via `.kamal/secrets`

### Thruster

[Thruster](https://github.com/basecamp/thruster) sits in front of Puma as an HTTP proxy:

- Adds HTTP caching headers
- Gzip compression
- X-Sendfile for static assets
- Runs as the container's entrypoint

---

## Key Architectural Patterns

### 1. Scope Chaining for Search

The `ChickenShopsController#index` builds queries by chaining ActiveRecord scopes conditionally. Each scope is independently testable and composable:

```ruby
@shops = ChickenShop.all
@shops = @shops.search_by_name(params[:search]) if params[:search].present?
@shops = @shops.with_min_rating(params[:rating]) if params[:rating].present?
# ...continues chaining
```

### 2. Toggle via Create

`ReviewReactionsController#create` implements a toggle pattern — the same endpoint handles both adding and removing reactions. This avoids separate create/destroy routes and simplifies the frontend.

### 3. Ownership Authorization via Association Scoping

Instead of finding a record globally and checking ownership, the app scopes finds through the current user's associations:

```ruby
# Safe — only finds the user's own reviews
@review = current_user.reviews.find(params[:id])
```

### 4. Idempotent Seeds

Seeds use `find_or_create_by!` so `db:seed` can be run repeatedly without duplicating data. This makes development setup reliable.

### 5. Bidirectional Relationships

Friendships and conversations model bidirectional user relationships. A friendship between User A and User B is stored as a single record where `user_id=A, friend_id=B`. The `for_user` scope queries both columns to find all friendships regardless of direction.

### 6. Polymorphic Associations for Flexibility

Three polymorphic associations (Activity `trackable`, Message `shareable`, Notification `notifiable`) allow the same table to reference different model types without separate foreign keys per type.

### 7. Callback-Driven Side Effects

Model callbacks handle cross-cutting concerns:

- `Review#after_create` → creates Activity
- `Friendship#after_create` → creates Notification
- `Friendship#after_update` → creates Activity + Notification
- `Message#after_create` → creates Notification

This keeps controllers thin but means side effects happen implicitly — understanding the full flow requires reading model callbacks.

### 8. No WebSockets

Despite including `solid_cable`, the app doesn't use Action Cable channels. All "real-time" updates are achieved via Turbo Stream responses to form submissions — the server responds with DOM instructions that Turbo applies client-side.
