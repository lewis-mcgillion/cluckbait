class CreateBadgesAndUserBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.string :description, null: false
      t.string :icon, null: false
      t.string :category, null: false
      t.integer :threshold, null: false, default: 1

      t.timestamps
    end

    add_index :badges, :key, unique: true
    add_index :badges, :category

    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_badges, [:user_id, :badge_id], unique: true
  end
end
