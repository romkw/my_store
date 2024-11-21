namespace :update do
  desc "Update stock for all products"
  task stock: :environment do
    puts "Оновлення stock для всіх продуктів..."
    
    stock_location = Spree::StockLocation.first_or_create!(
      name: 'default',
      default: true,
      active: true
    )

    Spree::Product.includes(:variants).find_each do |product|
      master_variant = product.master
      stock_item = Spree::StockItem.find_or_create_by!(
        variant: master_variant,
        stock_location: stock_location
      )
      
      current_stock = stock_item.count_on_hand
      if current_stock < 5
        adjustment = 5 - current_stock
        stock_item.adjust_count_on_hand(adjustment)
      end
      
      stock_item.update(backorderable: true)
      
      puts "Оновлено stock для продукту: #{product.name} (кількість: 5)"
    end

    puts "Оновлення stock завершено!"
  end
end 