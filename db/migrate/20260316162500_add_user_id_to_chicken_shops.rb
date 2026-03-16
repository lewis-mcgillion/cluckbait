class AddUserIdToChickenShops < ActiveRecord::Migration[8.0]
  def change
    add_column :chicken_shops, :user_id, :integer
    add_index :chicken_shops, :user_id
  end
end
