class CreateSpreeReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :spree_reviews do |t|
      t.string :reviewer_name
      t.text :comment
      t.integer :rating
      t.boolean :approved, default: false
      t.integer :product_id
      t.integer :user_id
      t.timestamps
    end

    add_index :spree_reviews, :product_id
    add_index :spree_reviews, :user_id
    add_index :spree_reviews, :reviewer_name
    
    add_column :spree_products, :avg_rating, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :spree_products, :reviews_count, :integer, default: 0
  end
end