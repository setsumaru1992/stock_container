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

      def save_stocks_price
        prices = ::WebAccessor::Sbi::StockPrice.new.get_prices_of_stocks
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

    def save_stock_price(price: nil)
      price ||= ::WebAccessor::Sbi::StockPrice.new.get_price_of(@code)
      day = Date.new - 1.day
    end
  end
end