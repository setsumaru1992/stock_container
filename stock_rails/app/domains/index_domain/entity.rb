module IndexDomain
  class Entity
    class << self
      def get_index_prices
        [
          ::IndexDomain::Codes::NIKKEI_AVERAGE,
          ::IndexDomain::Codes::DOW_AVERAGE
        ].map do |index_code|
          index_price = ::WebAccessor::Sbi::IndexPriceValue.new
          index_price.code = index_code
          index_price.chart_path = ::WebAccessor::Sbi::IndexPrice.new.get_concated_price_chart_image_path_of(index_code)
          index_price
        end
      end
    end
  end
end