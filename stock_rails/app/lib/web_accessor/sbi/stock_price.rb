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

    def get_portfolio_stock_prices
      raise "The logic needs credentials." unless @need_credential
      result_stock_prices = []
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETpfR001Control&_PageID=DefaultPID&_DataStoreID=DSWPLETpfR001Control&_ActionID=DefaultAID&getFlg=on")
        portfolio_rows = accessor.find_elements(:xpath, "/html/body/div[3]/div/table/tbody/tr/td/table[4]/tbody/tr[2]/td/table/tbody/tr")
        return [] if portfolio_rows.size <= 1 # ヘッダをのぞいて1つ以上行がない場合処理終了

        result_stock_prices = portfolio_rows[1..-1].map do |portfolio_row|
          stock_price = StockPriceValue.new
          stock_price.code = get_content(target_element: portfolio_row, selector: "./td[2]") do |content|
            matched = content.match(/(\d+)/)
            if matched.nil?
              # 海外株式の場合
              nil
            else
              matched[1].to_i
            end
          end
          next if stock_price.code.nil?
          stock_price.reference_price = get_content(target_element: portfolio_row, selector: "./td[5]") do |content|
            if content == "--"
              nil
            else
              content.gsub(",", "").to_i
            end
          end
          stock_price.price = get_content(target_element: portfolio_row, selector: "./td[6]") do |content|
            content.gsub(",", "").to_i
          end
          stock_price
        end.compact
      end
      result_stock_prices
    end

    def get_bought_stock_prices
      raise "The logic needs credentials." unless @need_credential
      result_stock_prices = []
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?OutSide=on&_ControlID=WPLETacR001Control&_PageID=DefaultPID&_DataStoreID=DSWPLETacR001Control&_SeqNo=2003_06_12_10_02_34.574_ExecuteThread%3A__45__for_queue%3A__wplExecute_Queue__WPLETlgR001Rlgn20_login&getFlg=on&_ActionID=DefaultAID&int_pr1=150313_cmn_gnavi:2_dmenu_01")
        # 株式（現物/NISA預り）
        # 保有株数    取得単価	  現在値	  評価損益
        # 8002 丸紅                  	現買 現売
        # 100	       672	    674.9	   +290
        # 8002 丸紅...
        bought_rows = accessor.find_elements(:xpath, "//form[@name='FORM']/table[2]/tbody/tr[1]/td[2]/table[5]/tbody/tr/td[3]/table[4]/tbody/tr")
        return [] if bought_rows.size <= 2
        result_stock_prices = bought_rows[2..-1].in_groups_of(2).map do |name_row, price_row|
          stock_price = StockPriceValue.new
          stock_price.code = get_content(target_element: name_row, selector: "./td[1]") do |content|
            content.match(/(\d+)/)[1].to_i
          end
          stock_price.reference_price = get_content(target_element: price_row, selector: "./td[2]") do |content|
            content.gsub(",", "").to_i
          end
          stock_price.price = get_content(target_element: price_row, selector: "./td[3]") do |content|
            content.gsub(",", "").to_i
          end
          stock_price
        end
      end
      result_stock_prices
    end

    def get_stock_prices
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
              stock.code = get_content(target_element: stock_row, selector: "./td[1]/div/p[2]") do |content|
                content.match(/(\d+)/)[1].to_i
              end
              stock.price = get_content(target_element: stock_row, selector: "./td[2]/div/p") do |content|
                price = content.gsub(",", "")
                next if price.to_i.to_s == price
                price.to_i
              end
              stock
            end.compact
          end.flatten
        end.flatten
      end
      stock_values
    end

    def get_price_chart_image_path_of(stock_code)
      range_keys = [
        WebAccessor::Sbi::ChartRange::ONE_YEAR,
        WebAccessor::Sbi::ChartRange::TWO_MONTH,
        WebAccessor::Sbi::ChartRange::FIVE_YEAR,
        WebAccessor::Sbi::ChartRange::TEN_YEAR
      ]
      get_concated_price_chart_image_path(stock_code, range_keys, "/var/opt/stock_container/chart_images/stocks")
    end

    def get_concated_price_chart_image_path(stock_code, range_keys, image_dir)
      image_path = nil
      access do |accessor|
        visit(stock_price_page_url_of(stock_code))
        image_path = get_concated_price_chart_image_path_in_iframe(
          "//*[@id='main']/div[6]/iframe",
          range_keys,
          "stock_#{stock_code}",
          image_dir
        )
      end
      image_path
    end

    private

    def stock_price_page_url_of(stock_code)
      "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Idtl30&_DataStoreID=DSWPLETsiR001Control&_ActionID=DefaultAID&s_rkbn=&s_btype=&i_dom_flg=1&i_exchange_code=&i_output_type=2&exchange_code=TKY&ref_from=1&ref_to=20&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=&qr_suggest=&qr_sort=&stock_sec_code_mul=#{stock_code}"
    end

    def stocks_url_of_industry(sample_industry_url, from, to)
      uri = URI::parse(sample_industry_url)
      params = URI::decode_www_form(uri.query).to_h
      params["ref_from"] = from.to_s
      params["ref_to"] = to.to_s
      uri.query = URI::encode_www_form(params)
      uri.to_s
    end
  end
end