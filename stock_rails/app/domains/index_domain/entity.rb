module IndexDomain
  class Entity
    class << self
      def get_index_prices(need_chart: false)
        web_accessor = ::WebAccessor::Sbi::IndexPrice.new(close_each_access: false)
        index_prices = [
          ::IndexDomain::Codes::NIKKEI_AVERAGE,
          ::IndexDomain::Codes::DOW_AVERAGE
        ].map do |index_code|
          index_price = web_accessor.get_price_of(index_code)
          next index_price unless need_chart
          index_price.chart_path = web_accessor.get_concated_price_chart_image_path_of(index_code)
          index_price
        end
        web_accessor.close
        index_prices
      end
    end
  end
end