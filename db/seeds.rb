require "json"

puts "🍗 Seeding Cluckbait..."
puts ""

# ── 1. Chicken Shops ─────────────────────────────────────────────────
shops_json = JSON.parse(File.read(Rails.root.join("db/seed_data/shops.json")))

shops_json.each do |data|
  ChickenShop.find_or_create_by!(name: data["name"], city: data["city"]) do |shop|
    shop.address     = data["address"]
    shop.postcode    = data["postcode"]
    shop.latitude    = data["latitude"]
    shop.longitude   = data["longitude"]
    shop.description = data["description"]
    shop.phone       = data["phone"]
    shop.website     = data["website"]
  end
end

puts "✅ #{ChickenShop.count} chicken shops"

# ── 2. Demo Users ────────────────────────────────────────────────────
users_json = JSON.parse(File.read(Rails.root.join("db/seed_data/users.json")))

password = "password123"

users_json.each do |data|
  User.find_or_create_by!(email: data["email"]) do |user|
    user.password = password
    user.display_name = data["name"]
    user.bio      = data["bio"]
  end
end

puts "✅ #{User.count} demo users (password: #{password})"

# ── 3. Reviews ───────────────────────────────────────────────────────
reviews_json = JSON.parse(File.read(Rails.root.join("db/seed_data/reviews.json")))

# Build lookup caches so we don't query per-review
shop_cache = {}
ChickenShop.find_each do |s|
  shop_cache["#{s.name}||#{s.city}"] = s
end

user_cache = {}
User.find_each { |u| user_cache[u.email] = u }

created = 0
reviews_json.each do |data|
  shop = shop_cache["#{data["shop_name"]}||#{data["shop_city"]}"]
  user = user_cache[data["user_email"]]
  next unless shop && user

  Review.find_or_create_by!(user: user, chicken_shop: shop, title: data["title"]) do |review|
    review.rating = data["rating"]
    review.body   = data["body"]
  end
  created += 1

  print "." if created % 50 == 0
end

puts ""
puts "✅ #{Review.count} reviews"
puts ""
puts "🍗 Seeding complete! Cluckbait is ready to go."
puts "   Log in with any demo account using password: #{password}"
puts "   e.g. cluckfan@example.com / #{password}"
