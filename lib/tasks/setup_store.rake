namespace :store do
  desc "Setup default store"
  task setup: :environment do
    # Знаходимо існуючий магазин або створюємо новий
    store = Spree::Store.find_or_initialize_by(code: 'pc-parts-store')
    
    # Оновлюємо всі інші магазини, щоб вони не були за замовчуванням
    Spree::Store.where.not(id: store.id).update_all(default: false)
    
    # Оновлюємо налаштування магазину
    store.update!(
      name: 'Магазин Комплектуючих для ПК',
      url: 'pc-parts.com',
      mail_from_address: 'roman.ivanyshyn-ip213@nung.edu.ua',
      default_currency: 'UAH',
      supported_currencies: 'UAH',
      default_locale: 'uk',
      supported_locales: 'uk',
      code: 'pc-parts-store', # Унікальний код
      default: true
    )
    
    puts "Магазин налаштовано:"
    puts "Назва: #{store.name}"
    puts "Валюта: #{store.default_currency}"
    puts "За замовчуванням: #{store.default?}"
    puts "Код: #{store.code}"
  end
end 