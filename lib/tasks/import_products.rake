namespace :import do
    desc "Import products from PC Cloud API"
    task products: :environment do
      require 'net/http'
      require 'json'
      require 'down'
  
      def fetch_products
        uri = URI('https://pc-cloud-server.vercel.app/products')
        puts "Запит до API: #{uri}"
  
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
        response = http.get(uri.path)
        puts "Статус відповіді: #{response.code}"
  
        if response.code == '200'
          data = JSON.parse(response.body)
          if data['data'].is_a?(Array)
            data['data']
          else
            puts "Неправильний формат даних"
            []
          end
        else
          puts "Помилка API: #{response.body}"
          []
        end
      rescue StandardError => e
        puts "Помилка отримання даних з API: #{e.message}"
        []
      end
  
      def create_product(item)
        store = Spree::Store.default
  
        price = item['price'].gsub(',', '').to_f
  
        product = Spree::Product.new(
          name: item['name'],
          description: item['description'],
          available_on: Time.current,
          shipping_category: Spree::ShippingCategory.first_or_create!(name: 'Default'),
          price: price,
          status: 'active'
        )
  
        product.stores << store
  
        if product.save
          variant = product.master
          variant.prices.create!(
            amount: price,
            currency: store.default_currency
          )
  
          begin
            tempfile = Down.download(item['img'])
  
            Spree::Image.create!(
              viewable_id: variant.id,
              viewable_type: 'Spree::Variant',
              attachment: File.open(tempfile.path)
            )
  
            tempfile.close
            tempfile.unlink
          rescue Down::Error => e
            puts "Помилка завантаження зображення для #{item['name']}: #{e.message}"
          end
  
          puts "Створено продукт: #{product.name} (#{price} #{store.default_currency})"
          true
        else
          puts "Помилка створення продукту: #{product.errors.full_messages.join(', ')}"
          false
        end
      rescue StandardError => e
        puts "Помилка при створенні продукту #{item['name']}: #{e.message}"
        false
      end
  
      puts "Початок імпорту продуктів..."
      products = fetch_products
  
      if products.any?
        puts "\nОтримано #{products.count} продуктів"
        successful_imports = 0
  
        products.each do |item|
          successful_imports += 1 if create_product(item)
        end
  
        puts "\nІмпорт завершено!"
        puts "Успішно імпортовано: #{successful_imports} з #{products.count} продуктів"
      else
        puts "Не вдалося отримати дані з API"
      end
    end
  end