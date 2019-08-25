module StockDomain::Repository
  class << self
    def not_existing_stock_codes(codes)
      existing_codes = ::Stock.where(code: codes).select(:code).map(&:code)
      codes - existing_codes
    end

    def stock_codes
      ::Stock.all.map(&:code)
    end

    def create_or_update_stock(attributes)
      stock = build_stock_model(attributes[:code])
      keys = [:code, :name, :kana, :industry_name, :settlement_month, :established_year, :listed_year, :listed_month, :category]
      update_model_fields_by_attribute(stock, attributes, keys)
      stock.save!
    end

    def create_or_update_stock_condition(attributes)
      stock_condition = build_stock_condition_model(attributes[:code], return_existing: true)
      keys = [:feature, :trend, :current_strategy, :category_rank, :big_stock_holder]
      stock_condition = update_model_fields_by_attribute(stock_condition, attributes, keys)
      stock_condition.save!
    end

    def create_or_update_stock_financial_condition(attributes)
      stock_financial_condition = build_stock_financial_condition_model(attributes[:code], return_existing: true)
      keys = [:market_capitalization, :buy_unit, :is_nikkei_average_group, :total_asset, :shareholder_equity, :common_share, :retained_earnings]
      stock_financial_condition = update_model_fields_by_attribute(stock_financial_condition, attributes, keys)
      stock_financial_condition.save!
    end

    def create_stock_performance(attributes)
      stock_performance = build_stock_performance_model(attributes[:code], attributes[:year], attributes[:month])
      return if stock_performance.nil?

      keys = [:year, :month, :net_sales, :operating_income, :ordinary_income, :net_income]
      stock_performance = update_model_fields_by_attribute(stock_performance, attributes, keys)
      stock_performance.save!
    end

    def create_stock_price(attributes)
      stock_price = build_stock_price_model(attributes[:code], attributes[:day])
      return if stock_price.nil?

      keys = [:day, :price]
      stock_price = update_model_fields_by_attribute(stock_price, attributes, keys)
      stock_price.save!
    end

    private

    def build_stock_model(code)
      ::Stock.find_or_create_by(code: code)
    end

    def build_stock_condition_model(code, return_existing: false)
      stock = ::Stock.find_by(code: code)
      existing = stock.stock_conditions.first
      return existing if return_existing && existing.present?
      if existing.present?
        nil
      else
        stock.stock_conditions.create
      end
    end

    def build_stock_financial_condition_model(code, return_existing: false)
      stock_financial_condition_record = ::Stock.find_by(code: code).stock_financial_conditions
      existing = stock_financial_condition_record.first
      return existing if return_existing && existing.present?
      if existing.present?
        nil
      else
        stock_financial_condition_record.create
      end
    end

    def build_stock_performance_model(code, year, month, return_existing: false)
      stock_performance_record = ::Stock.find_by(code: code).stock_performances
      conditions = {year: year, month: month}
      existing = stock_performance_record.find_by(conditions)

      return existing if return_existing && existing.present?
      if existing.present?
        nil
      else
        stock_performance_record.create
      end
    end

    def build_stock_price_model(code, day, return_existing: false)
      stock_price_record = ::Stock.find_by(code: code).stock_prices
      conditions = {day: day}

      return stock_price_record.find_or_create_by(conditions) if return_existing
      if stock_price_record.exists?(conditions)
        nil
      else
        stock_price_record.create
      end
    end

    def update_model_fields_by_attribute(model, attributes, keys)
      keys.each do |key|
        next unless attributes.has_key?(key)
        model.send("#{key}=", attributes[key])
      end
      model
    end
  end
end