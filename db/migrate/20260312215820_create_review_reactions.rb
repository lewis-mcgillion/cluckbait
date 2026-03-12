class CreateReviewReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :review_reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true
      t.string :kind, null: false

      t.timestamps
    end

    add_index :review_reactions, [ :user_id, :review_id, :kind ], unique: true
  end
end
