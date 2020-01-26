module StockDomain::Query
  class << self
    def base_stock_info(conditions, not_condition, condition_or_strs, order, current_price_day, latest_first_year, chart_day, range_type, page)
      stock_paginator = Stock
        .joins("LEFT OUTER JOIN stock_conditions ON stocks.id = stock_conditions.stock_id")
        .joins("LEFT OUTER JOIN stock_financial_conditions ON stocks.id = stock_financial_conditions.stock_id")
        .joins("LEFT OUTER JOIN stock_performances ON stocks.id = stock_performances.stock_id AND stock_performances.year = #{Date.today.year}")
        .joins("LEFT OUTER JOIN stock_prices ON stocks.id = stock_prices.stock_id AND stock_prices.day = '#{current_price_day}'")
        .joins("LEFT OUTER JOIN stock_performances AS latest_performances ON stocks.id = latest_performances.stock_id AND latest_performances.year = '#{latest_first_year}'")
        .joins("LEFT OUTER JOIN stock_performances AS ref_performances ON stocks.id = ref_performances.stock_id AND ref_performances.year = '#{latest_first_year - 1}'")
        .joins("LEFT OUTER JOIN stock_charts ON stocks.id = stock_charts.stock_id AND stock_charts.day = '#{chart_day}' AND stock_charts.range_type = #{range_type}")
        .joins("LEFT OUTER JOIN stock_favorites ON stocks.id = stock_favorites.stock_id")
        .where(conditions)
        .where(condition_or_strs.join(" OR "))
        .where.not(not_condition)
        .order(order)
        .page(page)
        .select("
                stocks.id
                , stocks.code
                , stocks.name
                , stocks.category
                , stocks.listed_year
                , stocks.listed_month
                , stock_conditions.feature
                , stock_conditions.category_rank
                , stock_financial_conditions.market_capitalization
                , stock_financial_conditions.is_nikkei_average_group
                , stock_financial_conditions.shareholder_equity
                , stock_prices.price
                , stock_charts.id as chart_id
                , stock_charts.image
                , stock_favorites.created_at AS favorite_date

                , latest_performances.net_sales AS latest_net_sales
                , ref_performances.net_sales AS ref_net_sales
                , (CASE
                    WHEN latest_performances.net_sales IS NOT NULL AND ref_performances.net_sales IS NOT NULL
                      THEN ((latest_performances.net_sales - ref_performances.net_sales) / ABS(ref_performances.net_sales)) * 100
                    ELSE NULL
                  END) AS net_sales_profit_rate

                , latest_performances.operating_income AS latest_operating_income
                , ref_performances.operating_income AS ref_operating_income
                , (CASE
                    WHEN latest_performances.operating_income IS NOT NULL AND ref_performances.operating_income IS NOT NULL
                      THEN ((latest_performances.operating_income - ref_performances.operating_income) / ABS(ref_performances.operating_income)) * 100
                    ELSE NULL
                  END) AS operating_income_profit_rate

                , latest_performances.ordinary_income AS latest_ordinary_income
                , ref_performances.ordinary_income AS ref_ordinary_income
                , (CASE
                    WHEN latest_performances.ordinary_income IS NOT NULL AND ref_performances.ordinary_income IS NOT NULL
                      THEN ((latest_performances.ordinary_income - ref_performances.ordinary_income) / ABS(ref_performances.ordinary_income)) * 100
                    ELSE NULL
                  END) AS ordinary_income_profit_rate

                , latest_performances.net_income AS latest_net_income
                , ref_performances.net_income AS ref_net_income
                , (CASE
                    WHEN latest_performances.net_income IS NOT NULL AND ref_performances.net_income IS NOT NULL
                      THEN ((latest_performances.net_income - ref_performances.net_income) / ABS(ref_performances.net_income)) * 100
                    ELSE NULL
                  END) AS net_income_profit_rate
                , stock_financial_conditions.market_capitalization / latest_performances.net_income AS per
                , stock_financial_conditions.market_capitalization / stock_financial_conditions.shareholder_equity AS pbr

                , (
                  SELECT smp.day
                  FROM stock_mean_prices smp
                  WHERE smp.stock_id = stocks.id
                    AND smp.has_day_golden_cross = 1
                    AND smp.day > '#{Date.today - 1.week}'
                  ORDER BY day DESC
                  LIMIT 1
                ) AS day_of_day_golden_cross

                , (
                  SELECT smp.day
                  FROM stock_mean_prices smp
                  WHERE smp.stock_id = stocks.id
                    AND smp.has_day_dead_cross = 1
                    AND smp.day > '#{Date.today - 1.week}'
                  ORDER BY day DESC
                  LIMIT 1
                ) AS day_of_day_dead_cross

                , (
                  SELECT smp.day
                  FROM stock_mean_prices smp
                  WHERE smp.stock_id = stocks.id
                    AND smp.has_week_golden_cross = 1
                    AND smp.day > '#{Date.today - 1.month}'
                  ORDER BY day DESC
                  LIMIT 1
                ) AS day_of_week_golden_cross

                , (
                  SELECT smp.day
                  FROM stock_mean_prices smp
                  WHERE smp.stock_id = stocks.id
                    AND smp.has_week_dead_cross = 1
                    AND smp.day > '#{Date.today - 1.month}'
                  ORDER BY day DESC
                  LIMIT 1
                ) AS day_of_week_dead_cross
                ")
      stocks =  stock_paginator.map { |stock| stock.attributes}
      [stock_paginator, stocks]
    end
  end
end