module WebAccessor::Sbi
  class MetalPrice < Base
    def get_price_of_gold
      metal_price_value = MetalPriceValue.new

      access do |accessor|
        # ログイン後の画面のサイドバーで貴金属のボタンをクリックして、https://gold.sbisec.co.jp/midas/homeを別タブで開く
        click_js_trigger(selector: "//*[@id='SUBAREA01']/div[1]/div/div/div/div/ul/li[7]/a")
        # click_js_trigger(selector: "//*[@id='MAINAREA01-INNER-R']/div[4]/div[2]")
        switch_to_new_tab
        # 購入情報・貴金属の値段が見れる口座管理のページに遷移
        click_js_trigger(selector: "//*[@id='accountmanagement']")

        current_gold_price_box = accessor.find_element(:xpath, "//*[@id='priceBoard_Gold']")
        metal_price_value.sell_price = get_content(
          target_element: current_gold_price_box, selector: "//*[@id='sell_gold_curr']") do |content|
          content.gsub(",", "").to_i
        end

        metal_price_value.diff_sell_price_from_previous_day = get_content(
          target_element: current_gold_price_box, selector: "//*[@id='sell_gold_diff']") do |content|
          content.split(" ").first.to_i
        end

        metal_price_value.buy_price = get_content(
          target_element: current_gold_price_box, selector: "//*[@id='buy_gold_curr']") do |content|
          content.gsub(",", "").to_i
        end

        metal_price_value.diff_buy_price_from_previous_day = get_content(
          target_element: current_gold_price_box, selector: "//*[@id='buy_gold_diff']") do |content|
          content.split(" ").first.to_i
        end

        my_gold_price_row = accessor.find_element(:xpath, "//*[@id='accountDetailsTable']/tbody/tr[2]")
        metal_price_value.reference_price = get_content(
          target_element: my_gold_price_row, selector: "./td[4]") do |content|
          content.gsub(",", "").gsub("円", "").to_i
        end
      end
      metal_price_value
    end

    def get_concated_price_chart_image_path
      range_keys = [
        ::StockChart::ONE_DAY,
        ::StockChart::TWO_MONTH,
        ::StockChart::ONE_YEAR,
        ::StockChart::FIVE_YEAR,
      ]
      get_concated_price_chart_image_path_of_selected_range(range_keys, "/var/opt/stock_container/chart_images/metal")
    end

    private

    def get_concated_price_chart_image_path_of_selected_range(range_keys, image_dir)
      image_path = nil
      access do |_|
        visit(yen_to_usd_url)
        image_path = get_concated_price_chart_image_path_in_iframe(
          "//*[@id='idxdtlMultiChart']",
          range_keys,
          "gold",
          image_dir
        )
      end
      image_path
    end

    def chart_url
      ""
    end
  end
end