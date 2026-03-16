class AddUniqueIndexToReviews < ActiveRecord::Migration[8.1]
  def up
    # Remove duplicate reviews, keeping the most recent one per user/chicken_shop pair
    execute <<~SQL
      DELETE FROM reviews
      WHERE id NOT IN (
        SELECT MAX(id) FROM reviews
        GROUP BY user_id, chicken_shop_id
      )
    SQL

    remove_index :reviews, :user_id
    add_index :reviews, [:user_id, :chicken_shop_id], unique: true
  end

  def down
    remove_index :reviews, [:user_id, :chicken_shop_id]
    add_index :reviews, :user_id
  end
end
