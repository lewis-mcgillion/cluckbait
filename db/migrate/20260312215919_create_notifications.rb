class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :actor_id
      t.string :action, null: false
      t.string :notifiable_type
      t.integer :notifiable_id
      t.datetime :read_at

      t.timestamps
    end

    add_foreign_key :notifications, :users, column: :actor_id
    add_index :notifications, [:user_id, :read_at]
    add_index :notifications, [:notifiable_type, :notifiable_id]
  end
end
