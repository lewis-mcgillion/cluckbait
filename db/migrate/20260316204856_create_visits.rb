class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.string :ip_address, null: false
      t.datetime :visited_at, null: false
    end

    add_index :visits, :ip_address
    add_index :visits, :visited_at
    add_index :visits, [:ip_address, :visited_at]
  end
end
