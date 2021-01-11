module WebAccessor
  module Sbi
    class IndexPrice < Base
      include ::WebAccessor::Sbi::Method::ChartImageCreatable

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
        chart_settings = [
          ChartSetting.new(
            ChartSetting::Range::ONE_DAY,
            ChartSetting::ChartUnit::ONE_HOUR,
            ChartSetting::Technical::WEIGHTED_MOVING_AVERAGE_2LINE,
            ChartSetting::Technical::MACD,
          ),
          ChartSetting.new(
            ChartSetting::Range::TWO_MONTH,
            ChartSetting::ChartUnit::ONE_DAY,
            ChartSetting::Technical::WEIGHTED_MOVING_AVERAGE_2LINE,
            ChartSetting::Technical::MACD,
          ),
          ChartSetting.new(
            ChartSetting::Range::ONE_YEAR,
            ChartSetting::ChartUnit::ONE_DAY,
            ChartSetting::Technical::WEIGHTED_MOVING_AVERAGE_2LINE,
            ChartSetting::Technical::MACD,
          ),
          ChartSetting.new(
            ChartSetting::Range::FIVE_YEAR,
            ChartSetting::ChartUnit::ONE_WEEK,
            ChartSetting::Technical::WEIGHTED_MOVING_AVERAGE_2LINE,
            ChartSetting::Technical::MACD,
          ),
        ]
        get_concated_price_chart_image_path_of_selected_range(index_code, chart_settings, "/var/opt/stock_container/chart_images/indexes")
      end

      def get_price_chart_image_paths_of_nikkei_and_dow(image_dir)
        chart_settings = [
          ChartSetting.new(
            ChartSetting::Range::ONE_YEAR,
            ChartSetting::ChartUnit::ONE_DAY,
            ChartSetting::Technical::WEIGHTED_MOVING_AVERAGE_2LINE,
            ChartSetting::Technical::MACD,
          ),
          ChartSetting.new(
            ChartSetting::Range::TEN_YEAR,
            ChartSetting::ChartUnit::ONE_MONTH,
            ChartSetting::Technical::WEIGHTED_MOVING_AVERAGE_2LINE,
            ChartSetting::Technical::MACD,
          ),
        ]

        image_paths = [
          ::IndexDomain::Codes::NIKKEI_AVERAGE,
          ::IndexDomain::Codes::DOW_AVERAGE
        ].map do |index_code|
          image_paths_of_index_code = nil
          access do |_|
            visit(index_price_page_url_of(index_code))
            image_paths_of_index_code = get_price_chart_image_paths_in_iframe(
              "//*[@id='idxdtlMultiChart']",
              chart_settings,
              "index_#{index_code}",
              image_dir
            )
          end
          image_paths_of_index_code
        end.flatten
      end

      private

      def get_concated_price_chart_image_path_of_selected_range(index_code, chart_settings, image_dir)
        image_path = nil
        access do |_|
          visit(index_price_page_url_of(index_code))
          image_path = get_concated_price_chart_image_path_in_iframe(
            "//*[@id='idxdtlMultiChart']",
            chart_settings,
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