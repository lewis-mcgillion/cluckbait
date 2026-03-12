class AddUniqueIndexToReviewsOnUserAndChickenShop < ActiveRecord::Migration[8.0]
  def change
    add_index :reviews, [ :user_id, :chicken_shop_id ], unique: true
  end
end
