class AddUserIdToChickenShops < ActiveRecord::Migration[8.1]
  def change
    add_column :chicken_shops, :user_id, :integer
    add_index :chicken_shops, :user_id
    add_foreign_key :chicken_shops, :users
  end
end
