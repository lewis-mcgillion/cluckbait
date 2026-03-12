class CreateChickenShops < ActiveRecord::Migration[8.0]
  def change
    create_table :chicken_shops do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :postcode
      t.float :latitude
      t.float :longitude
      t.text :description
      t.string :phone
      t.string :website

      t.timestamps
    end
  end
end
