module FxDomain
  class Entity
    class << self
      def get_fx_prices(need_chart: false)
        web_accessor = ::WebAccessor::Sbi::FxPrice.new
        fx_price = web_accessor.get_price_of_yen_to_usd
        return [fx_price] unless need_chart
        image_path = web_accessor.get_concated_price_chart_image_path
        ::ImageManager::FxChart::YenToUsdInShortTerm.upload(image_path)
        fx_price.chart_path = image_path
        [fx_price]
      end
    end
  end
end