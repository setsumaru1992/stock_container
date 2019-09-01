require "csv"

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
            Rails.logger.error(e)
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
            Rails.logger.error(e)
            Rails.logger.warn("証券番号#{stock_price.code}の株価の取得に失敗しました。")
          end
        end
      end

      def save_stock_mean_prices(day: Date.today)
        day = day_of_price(day: day) if day == Date.today
        return if weekend?(day)
        codes = ::StockDomain::Repository.stock_codes

        codes.each do |code|
          entity = self.new(code)
          begin
            entity.save_mean_price(day: day)
          rescue => e
            Rails.logger.error(e)
            Rails.logger.warn("証券番号#{code}の株価の平均値計算に失敗しました。")
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

      def day_of_price(day: Date.today)
        time = Time.now
        if 0 <= time.hour && time.hour < 9
          day - 1.day
        else
          day
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
      base_company_info = web_accessor.get_company_base_info_of(@code)
      return if base_company_info.nil?
      web_value.merge!(base_company_info)
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

    def save_mean_price(day: Date.today)
      mean_1week, mean_5week, mean_3month, mean_6month = mean_values_of(day: day)
      return if mean_1week.nil?
      Repository.create_mean_price(code: @code, day: day, mean_1week: mean_1week, mean_5week: mean_5week, mean_3month: mean_3month, mean_6month: mean_6month)

      previous_day = previous_day_of(day)
      return if previous_day.nil?
      _, previous_mean_5week, previous_mean_3month, previous_mean_6month = mean_values_of(day: previous_day)

      # 日足ゴールデンクロス・デッドクロス。25日平均線が75日平均線（3ヶ月）を超えたかどうか
      has_day_golden_cross, has_day_dead_cross = has_golden_or_dead_cross?(mean_5week, mean_3month, previous_mean_5week, previous_mean_3month)
      # 週足ゴールデンクロス・デッドクロス。13週平均線（≒3ヶ月）が26週平均線（≒6ヶ月）を超えたかどうか
      has_week_golden_cross, has_week_dead_cross = has_golden_or_dead_cross?(mean_3month, mean_6month, previous_mean_3month, previous_mean_6month)
      Repository.update_cross_value(code: @code, day: day, has_day_golden_cross: has_day_golden_cross, has_day_dead_cross: has_day_dead_cross, has_week_golden_cross: has_week_golden_cross, has_week_dead_cross: has_week_dead_cross)
    end

    private

    def mean_values_of(day: Date.today)
      return [nil, nil, nil, nil, nil] if Stock.find_by(code: @code).stock_prices.find_by(day: day).nil?
      prices = Stock.find_by(code: @code).stock_prices.where("day <= ?", day).order("day DESC").limit(150).map(&:price)

      return [nil, nil, nil, nil, nil] unless prices.size >= 5
      mean_5week = nil
      mean_3month = nil
      mean_6month = nil

      mean_1week = mean_of(prices, 5)
      mean_5week = mean_of(prices, 25) if prices.size >= 25
      mean_3month = mean_of(prices, 75) if prices.size >= 75
      mean_6month = mean_of(prices, 150) if prices.size >= 150
      [mean_1week, mean_5week, mean_3month, mean_6month]
    end

    def mean_of(arr, size)
      arr.take(size).sum / size
    end

    def previous_day_of(day)
      today_and_previous_day = Stock.find_by(code: @code).stock_prices.where("day <= ?", day).order("day DESC").limit(2).map(&:day)
      return if today_and_previous_day.size != 2
      today_and_previous_day.last
    end

    def has_golden_or_dead_cross?(short_range_price, long_range_price, previous_short_range_price, previous_long_range_price)
      return [nil, nil] if [short_range_price, long_range_price, previous_short_range_price, previous_long_range_price].select {|value| value.nil?}.size > 0
      has_short_range_golden_cross = short_range_price > long_range_price && previous_short_range_price <= previous_long_range_price
      has_short_range_dead_cross = short_range_price < long_range_price && previous_short_range_price >= previous_long_range_price
      [has_short_range_golden_cross, has_short_range_dead_cross]
    end
  end
end