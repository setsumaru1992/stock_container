module WebAccessor::Sbi
  class StockInfoValue
    include Concerns::Hashable

    attr_accessor :code,
                  :industry_name, # 産業名
                  # 企業概要
                  :name, # 名称
                  :kana, # カナ
                  :settlement_month, # 決算月
                  :established_year, # 設立年
                  :listed_year, # 上場年
                  :listed_month, # 上場月
                  :feature, # 特徴
                  :trend, # トレンド
                  :current_strategy, # 戦略
                  :category, # 業種
                  :category_rank, # 業種内順位
                  :big_stock_holder, # 大株主
                  # 財務状況
                  :stock_performance_values, # 業績リスト
                  :market_capitalization, # 時価総額
                  :buy_unit, # 売買単位
                  :is_nikkei_average_group, # 日経平均グループフラグ
                  :total_asset, # 総資産
                  :shareholder_equity, # 自己資本
                  :common_share, # 資本金
                  :retained_earnings # 利益剰余金
  end
end