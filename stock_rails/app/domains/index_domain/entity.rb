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

      def update_chart_image
        web_accessor = ::WebAccessor::Sbi::IndexPrice.new
        image_dir = Rails.root.join("tmp")
        image_paths = web_accessor.get_price_chart_image_paths_of_nikkei_and_dow(image_dir)
        concated_image_path = "#{image_dir}/#{"index_chart_nikkei_and_dow.jpeg"}"
        ::ImageManager::Base.concate_images(image_paths, concated_image_path)
        ::ImageManager::FxChart::NikkeiAndDowInLongTerm.upload(concated_image_path)
        ::FileUtils.rm(concated_image_path)
      end
    end
  end
end