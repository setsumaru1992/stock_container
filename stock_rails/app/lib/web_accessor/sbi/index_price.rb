module WebAccessor
  module Sbi
    class IndexPrice < Base
      def get_price_of(index_code)

      end

      def get_concated_price_chart_image_path_of(index_code)
        range_keys = [
          ::StockChart::ONE_YEAR,
          ::StockChart::TWO_MONTH,
          ::StockChart::FIVE_YEAR,
          ::StockChart::TEN_YEAR
        ]
        get_concated_price_chart_image_path(index_code, range_keys, "/var/opt/stock_container/chart_images/indexes")
      end

      private

      def get_concated_price_chart_image_path(index_code, range_keys, image_dir)
        image_path = nil
        access do |accessor|
          visit(index_price_page_url_of(index_code))
          image_path = get_concated_price_chart_image_path_in_iframe(
            "//*[@id='idxdtlMultiChart']",
            range_keys,
            "index_#{index_code}",
            image_dir
          )
        end
        image_path
      end

      def index_price_page_url_of(index_code)
        "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETmgR001Control&_PageID=WPLETmgR001Mdtl20&_DataStoreID=DSWPLETmgR001Control&_ActionID=DefaultAID&burl=iris_indexDetail&cat1=market&cat2=index&file=index.html&getFlg=on&dir=tl1-idxdtl%7Ctl2-.#{IndexParams::INDEX_URL_CODE_HASH[index_code]}%7Ctl5-jpn"
      end
    end
  end
end