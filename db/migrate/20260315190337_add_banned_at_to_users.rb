class AddBannedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :banned_at, :datetime
  end
end
