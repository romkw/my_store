module Spree
  module HomeControllerDecorator
    def index
      @products = Spree::Product.available.includes(:variants_including_master, master: [:default_price, :images]).limit(8)
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      render 'spree/home/index'
    end
  end
end

Spree::HomeController.prepend Spree::HomeControllerDecorator 