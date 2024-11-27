module Spree
  class Review < ApplicationRecord
    belongs_to :product, class_name: 'Spree::Product'
    belongs_to :user, class_name: 'Spree::User', optional: true

    validates :reviewer_name, presence: true
    validates :rating, presence: true, inclusion: { in: 1..5 }
    validates :comment, presence: true

    after_save :update_product_rating
    after_destroy :update_product_rating

    private

    def update_product_rating
      product.update_columns(
        avg_rating: product.reviews.average(:rating) || 0,
        reviews_count: product.reviews.count
      )
    end
  end
end 