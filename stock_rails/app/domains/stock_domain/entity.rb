module StockDomain
  class Entity

    class << self
      def save_stock_informations(ignore_existing_stock_code: true)
        stock_values = ::WebAccessor::Sbi::StockInfo.new.get_stocks
        codes = stock_values.map(&:code)
        codes = ::StockDomain::Repository.not_existing_stock_codes(codes) if ignore_existing_stock_code
        codes.each do |code|
          entity = self.new(code)
          begin
            entity.save_stock_information
          rescue => e
            Rails.logger.warn("証券番号#{code}の株情報の取得に失敗しました。")
          end
        end
      end

      def save_stock_prices
        day = day_of_price
        return if weekend?(day)
        stock_prices = ::WebAccessor::Sbi::StockPrice.new.get_stock_prices

        stock_prices.each do |stock_price|
          entity = self.new(stock_price.code)
          begin
            entity.save_stock_price(price: stock_price.price, day: day)
          rescue => e
            Rails.logger.warn("証券番号#{stock_price.code}の株価の取得に失敗しました。")
          end
        end
      end

      def get_favorite_stock_prices(user_id, need_chart: false)
        user_name, read_password = sbi_credential_from(user_id)
        return if user_name.nil? || read_password.nil?
        stock_prices = ::WebAccessor::Sbi::StockPrice
          .new(need_credential: true, user_name: user_name, password: read_password)
          .get_portfolio_stock_prices
        return stock_prices unless need_chart
        stock_prices.map do |stock_price|
          stock_price.chart_path = ::WebAccessor::Sbi::StockPrice.new.get_price_chart_image_path_of(stock_price.code)
          stock_price
        end
      end

      def get_bought_stock_prices(user_id, need_chart: false)
        user_name, read_password = sbi_credential_from(user_id)
        return if user_name.nil? || read_password.nil?
        stock_prices = ::WebAccessor::Sbi::StockPrice
          .new(need_credential: true, user_name: user_name, password: read_password)
          .get_bought_stock_prices
        return stock_prices unless need_chart
        stock_prices.map do |stock_price|
          stock_price.chart_path = ::WebAccessor::Sbi::StockPrice.new.get_price_chart_image_path_of(stock_price.code)
          stock_price
        end
      end

      # private
      # 本来privateな日付取得ロジック。インスタンスから使うためpublic化

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

      private

      def sbi_credential_from(user_id)
        credential = User.find(user_id).sbi_credentials.first
        return [nil, nil] if credential.nil?
        [credential.user_name, credential.read_password]
      end
    end

    def initialize(code)
      @code = code
    end

    def save_stock_information
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