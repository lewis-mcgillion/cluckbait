class DropBadgesAndUserBadges < ActiveRecord::Migration[8.1]
  def change
    drop_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true
      t.timestamps
    end

    drop_table :badges do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.string :description
      t.string :icon
      t.string :category
      t.integer :threshold
      t.timestamps
    end
  end
end
