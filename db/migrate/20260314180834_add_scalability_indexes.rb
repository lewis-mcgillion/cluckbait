class AddScalabilityIndexes < ActiveRecord::Migration[8.1]
  def change
    # Search indexes for chicken_shops (currently has no indexes)
    add_index :chicken_shops, :name
    add_index :chicken_shops, :city
    add_index :chicken_shops, [:latitude, :longitude], name: "index_chicken_shops_on_coordinates"

    # Counter caches
    add_column :chicken_shops, :reviews_count, :integer, default: 0, null: false
    add_column :users, :reviews_count, :integer, default: 0, null: false

    # Composite index for ordered reviews per shop
    add_index :reviews, [:chicken_shop_id, :created_at], name: "index_reviews_on_shop_and_created_at"
  end
end
