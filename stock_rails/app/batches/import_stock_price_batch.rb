require "csv"

class ImportStockPriceBatch
  class << self
    def exec_from(stock_price_dir)
      Dir.foreach(stock_price_dir) do |stock_price_file|
        next if stock_price_file.start_with? "."
        self.new.run("#{stock_price_dir}/#{stock_price_file}")
      end
    end
  end

  def run(stock_price_file)
    stock_prices = CSV.read(stock_price_file, headers: true)

    code = stock_price_file.match(/([0-9]+).csv/)[1]&.to_i
    Rails.logger.info("#{stock_price_file}から証券番号#{code}のStockPriceの読み込みを開始します")

    stock_id = Stock.find_by(code: code).id
    existing_stock_price_days = StockPrice.joins(:stock).where(stocks: {code: code}).pluck(:day)

    stock_prices.delete_if do |stock_price|
      existing_stock_price_days.include?(Date.parse(stock_price["date"]))
    end

    stock_prices.each_slice(1000) do |batch_stock_prices|
      stock_price_targets = batch_stock_prices.map do |stock_price|
        StockPrice.new(
            stock_id: stock_id,
            price: stock_price["value"],
            day: stock_price["date"]
        )
      end
      StockPrice.import(stock_price_targets)
    end
    Rails.logger.info("#{stock_price_file}から証券番号#{code}のStockPriceの読み込みを終了します")
  end
end