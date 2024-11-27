module Spree
  module ProductDecorator
    def self.prepended(base)
      base.has_many :reviews, dependent: :destroy
    end

    def display_rating
      avg_rating.to_f.round(1)
    end

    def reviews_count_text
      "#{reviews_count} #{I18n.t('spree.reviews', count: reviews_count)}"
    end
  end
end

Spree::Product.prepend Spree::ProductDecorator 