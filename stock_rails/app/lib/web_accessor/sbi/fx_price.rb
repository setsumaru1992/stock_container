module WebAccessor::Sbi
  class FxPrice < Base
    def get_price_of_yen_to_usd
      fx_price_value = FxPriceValue.new

      access do |_|
        visit(yen_to_usd_url)

        no_value = "--"
        fx_price_value.price = get_content(selector: "//*[@id='idxdtlBidAsk']/em") do |content|
          content.split("-").first.to_f
        end

        fx_price_value.reference_price = get_content(selector: "//*[@id='idxdtlClose']/b") do |content|
          content.split("-").first.to_f
        end
      end
      fx_price_value
    end

    def get_concated_price_chart_image_path
      range_keys = [
        ::StockChart::ONE_DAY,
        ::StockChart::TWO_MONTH,
        ::StockChart::ONE_YEAR,
        ::StockChart::FIVE_YEAR,
      ]
      get_concated_price_chart_image_path_of_selected_range(range_keys, "/var/opt/stock_container/chart_images/fx")
    end

    private

    def get_concated_price_chart_image_path_of_selected_range(range_keys, image_dir)
      image_path = nil
      access do |_|
        visit(yen_to_usd_url)
        image_path = get_concated_price_chart_image_path_in_iframe(
          "//*[@id='idxdtlMultiChart']",
          range_keys,
          "fx_yen_to_usd",
          image_dir
        )
      end
      image_path
    end

    def yen_to_usd_url
      "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETmgR001Control&_PageID=WPLETmgR001Mdtl20&_DataStoreID=DSWPLETmgR001Control&_ActionID=DefaultAID&burl=iris_indexDetail&cat1=market&cat2=index&dir=tl1-idxdtl%7Ctl2-JPY%3DX%7Ctl5-jpn&file=index.html&getFlg=on&OutSide=on"
    end
  end
end
