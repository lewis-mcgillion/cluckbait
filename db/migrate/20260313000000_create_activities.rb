class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.string :trackable_type
      t.integer :trackable_id

      t.timestamps
    end

    add_index :activities, [ :user_id, :created_at ]
    add_index :activities, [ :trackable_type, :trackable_id ]
  end
end
