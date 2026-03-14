class CreateWishlistItems < ActiveRecord::Migration[8.1]
  def change
    create_table :wishlist_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chicken_shop, null: false, foreign_key: true
      t.boolean :visited, default: false, null: false
      t.text :notes

      t.timestamps
    end

    add_index :wishlist_items, [:user_id, :chicken_shop_id], unique: true
  end
end
