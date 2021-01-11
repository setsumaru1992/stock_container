module WebAccessor
  module Sbi
    class IndexPrice < Base
      def get_price_of(index_code)
        index_price_value = IndexPriceValue.new
        index_price_value.code = index_code

        access do |_|
          visit(index_price_page_url_of(index_code))

          no_value = "--"
          index_price_value.price = get_content(selector: "//*[@id='idxdtlPrice']/em") do |content|
            price_icon = get_content(selector: "//*[@id='idxdtlPrice']/em/span")
            content = content.gsub(price_icon, "")
            break if content == no_value
            content.gsub(",", "").to_i
          end
          index_price_value.reference_price = get_content(selector: "//*[@id='idxdtlClose']/b") do |content|
            break if content == no_value
            content.gsub(",", "").to_i
          end
        end
        index_price_value
      end

      def get_concated_price_chart_image_path_of(index_code)
        range_keys = [
          ::StockChart::ONE_DAY,
          ::StockChart::TWO_MONTH,
          ::StockChart::ONE_YEAR,
          ::StockChart::FIVE_YEAR,
        ]
        get_concated_price_chart_image_path(index_code, range_keys, "/var/opt/stock_container/chart_images/indexes")
      end

      def get_concated_price_chart_image_path_of_nikkei_and_dow
        range_keys = [
          ::StockChart::ONE_YEAR,
          ::StockChart::FIVE_YEAR,
        ]
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