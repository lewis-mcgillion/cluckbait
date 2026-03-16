class AddUniqueIndexToReviews < ActiveRecord::Migration[8.1]
  def change
    remove_index :reviews, :user_id
    add_index :reviews, [:user_id, :chicken_shop_id], unique: true
  end
end
