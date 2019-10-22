module IndexDomain
  class Entity
    class << self
      def get_index_prices(need_chart: false)
        [
          # ::IndexDomain::Codes::NIKKEI_AVERAGE,
          ::IndexDomain::Codes::DOW_AVERAGE
        ].map do |index_code|
          index_price = ::WebAccessor::Sbi::IndexPrice.new.get_price_of(index_code)
          next index_price unless need_chart
          index_price.chart_path = ::WebAccessor::Sbi::IndexPrice.new.get_concated_price_chart_image_path_of(index_code)
          index_price
        end
      end
    end
  end
end