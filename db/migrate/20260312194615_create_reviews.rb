class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chicken_shop, null: false, foreign_key: true
      t.integer :rating
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
