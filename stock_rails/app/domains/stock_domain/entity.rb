module StockDomain
  class Entity
    class << self
      def save_stocks_info(ignore_existing_stock_code: true)
        stock_values = ::WebAccessor::Sbi::StockInfo.new.get_stocks
        codes = stock_values.map(&:code)
        codes = ::StockDomain::Repository.not_existing_stock_codes(codes) if ignore_existing_stock_code
        codes.each do |code|
          entity = self.new(code)
          begin
            entity.save_stock_info
          rescue => e
            Rails.logger.warn("証券番号#{code}の株情報の取得に失敗しました。")
          end
        end
      end

      def save_price_of_stocks
        day = day_of_price
        return if weekend?(day)
        stock_prices = ::WebAccessor::Sbi::StockPrice.new.get_prices_of_stocks

        stock_prices.each do |stock_price|
          entity = self.new(stock_price.code)
          begin
            entity.save_stock_price(price: stock_price.price, day: day)
          rescue => e
            Rails.logger.warn("証券番号#{stock_price.code}の株価の取得に失敗しました。")
          end
        end
      end

      def day_of_price
        time = Time.now
        if 0 <= time.hour && time.hour < 9
          Date.today - 1.day
        else
          Date.today
        end
      end

      def weekend?(day)
        day.saturday? || day.sunday?
      end
    end

    def initialize(code)
      @code = code
    end

    def save_stock_info
      web_accessor = ::WebAccessor::Sbi::StockInfo.new
      web_value = ::WebAccessor::Sbi::StockInfoValue.new
      web_value.merge!(web_accessor.get_company_base_info_of(@code))
      Repository.create_or_update_stock(web_value.to_h)
      Repository.create_or_update_stock_condition(web_value.to_h)

      web_value.merge!(web_accessor.get_financial_info_of(@code))
      Repository.create_or_update_stock_financial_condition(web_value.to_h)
      web_value.stock_performance_values.each do |stock_performance_value|
        Repository.create_stock_performance(stock_performance_value.to_h.merge!({code: web_value.code}))
      end
    end

    def save_stock_price(price: nil, day: nil)
      day ||= ::StockDomain::Entity.day_of_price
      return if ::StockDomain::Entity.weekend?(day)
      price ||= ::WebAccessor::Sbi::StockPrice.new.get_price_of(@code)
      Repository.create_stock_price(code: @code, day: day, price: price)
    end
  end
end