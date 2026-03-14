class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.string :shareable_type
      t.bigint :shareable_id
      t.timestamps
    end

    add_index :messages, [:shareable_type, :shareable_id]
  end
end
