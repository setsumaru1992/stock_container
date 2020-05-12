module MetalDomain
  class Entity
    class << self
      def get_gold_price(need_chart: false)
        web_accessor = ::WebAccessor::Sbi::MetalPrice.new
        gold_value = web_accessor.get_price_of_gold
        return [gold_value] unless need_chart
        gold_value.chart_path = web_accessor.get_concated_price_chart_image_path
        [gold_value]
      end
    end
  end
end