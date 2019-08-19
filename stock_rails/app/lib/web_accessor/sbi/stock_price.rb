module WebAccessor::Sbi
  class StockPrice < Base

    def get_price_of(stock_code)
      price = nil
      access do |accessor|
        visit(stock_price_page_url_of(stock_code))
        price = get_content(selector: "//*[@id='main']/div[5]/div/table/tbody/tr/td[1]/em") do |content|
          content.gsub(",", "").to_i
        end
      end
      price
    end

    def get_prices_of_stocks
      stock_values = []
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Iser10&_DataStoreID=DSWPLETsiR001Control&_ActionID=goToStockPriceListByIndustry&OutSide=on")

        industry_rows = accessor.find_elements(:xpath, "//*[@id='main']/div[4]/table/tbody/tr")
        industries_without_stocks = industry_rows.map do |industry_row|
          link_tag = industry_row.find_element(:xpath, "./td[2]/div/p/a")
          industry = StockIndustryValue.new
          industry.name = link_tag.text
          industry.url = link_tag.attribute("href")
          industry
        end

        stock_values = industries_without_stocks.map do |industry|
          visit(industry.url)
          stock_count = get_content(selector: "//*[@id='main']/table/tbody/tr/td/form/div[1]/div[2]/p") do |content|
            content.match(/(\d+)件中/)[1].to_i
          end
          (1..stock_count).each_slice(100).map do |stock_idxs|
            visit(stocks_url_of_industry(industry.url, stock_idxs.first, stock_idxs.last))
            stock_rows = accessor.find_elements(:xpath, "//*[@id='main']/table/tbody/tr/td/form/div[2]/div/table/tbody/tr")
            stock_rows.map do |stock_row|
              stock = StockPriceValue.new
              stock.stock_code = get_content(target_element: stock_row, selector: "./td[1]/div/p[2]") do |context|
                context.match(/(\d+)/)[1].to_i
              end
              stock.price = get_content(target_element: stock_row, selector: "./td[2]/div/p") do |context|
                context.gsub(",", "").to_i
              end
              stock
            end
          end.flatten
        end.flatten
      end
      stock_values
    end

    def get_concated_price_chart_image_path(stock_code, range_keys)
      image_path = nil
      access do |accessor|
        visit(stock_price_page_url_of(stock_code))
        image_path = get_concated_price_chart_image_path_in_iframe("//*[@id='main']/div[6]/iframe", range_keys, "stock_#{stock_code}")
      end
      image_path
    end

    private

    def stock_price_page_url_of(stock_code)
      "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Idtl30&_DataStoreID=DSWPLETsiR001Control&_ActionID=DefaultAID&s_rkbn=&s_btype=&i_dom_flg=1&i_exchange_code=&i_output_type=2&exchange_code=TKY&ref_from=1&ref_to=20&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=&qr_suggest=&qr_sort=&stock_sec_code_mul=#{stock_code}"
    end
  end
end