module WebAccessor::Sbi
  class StockInfo < Base
    def get_stocks
      stocks = []
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

        stocks = industries_without_stocks.map do |industry|
          visit(industry.url)
          stock_count = get_content(selector: "//*[@id='main']/table/tbody/tr/td/form/div[1]/div[2]/p") do |content|
            content.match(/(\d+)件中/)[1].to_i
          end
          (1..stock_count).each_slice(100).map do |stock_idxs|
            visit(stocks_url_of_industry(industry.url, stock_idxs.first, stock_idxs.last))
            stock_rows = accessor.find_elements(:xpath, "//*[@id='main']/table/tbody/tr/td/form/div[2]/div/table/tbody/tr")
            stock_rows.map do |stock_row|
              stock = StockInfoValue.new
              stock.industry_name = industry.name
              stock.name = get_content(target_element: stock_row, selector: "./td[1]/div/p[1]")
              stock.code = get_content(target_element: stock_row, selector: "./td[1]/div/p[2]") do |context|
                context.match(/(\d+)/)[1].to_i
              end
              stock
            end
          end.flatten
        end.flatten
      end
      stocks
    end

    def get_company_base_info_of(stock_code)
      result_value = StockInfoValue.new
      result_value.code = stock_code
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Idtl50&_DataStoreID=DSWPLETsiR001Control&_ActionID=DefaultAID&s_btype=&i_dom_flg=1&i_exchange_code=JPN&i_output_type=4&exchange_code=TKY&ref_from=1&ref_to=20&getFlg=on&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=1&qr_suggest=1&qr_sort=1&stock_sec_code_mul=#{stock_code}")

        base_selector = "//*[@id='main']/div[8]"
        company_info_selector = "#{base_selector}/table[1]/tbody"

        return if accessor.find_element(:xpath, "#{company_info_selector}/tr[2]").nil?
        name_and_kana = get_content(selector: "#{company_info_selector}/tr[2]") do |content| # (例)7974   任天堂    にんてんどう   ［ その他製品 ］
          content.match(/\d+\s+(\S+)\s+(\S+)\s+\S.*/)
        end
        result_value.name = name_and_kana[1]
        result_value.kana = name_and_kana[2]

        result_value.settlement_month = get_content(selector: "#{company_info_selector}/tr[4]") do |content| # (例)【決算】3月
          content.gsub("【決算】", "").gsub("月", "").to_i
        end

        result_value.established_year = get_content(selector: "#{company_info_selector}/tr[5]") do |content| # (例)【設立】1947.11
          content.gsub("【設立】", "").split(".")[0].to_i
        end

        listed_year_month = get_content(selector: "#{company_info_selector}/tr[6]") do |content| # (例)【上場】1962.1
          content.gsub("【上場】", "").split(".")
        end
        result_value.listed_year = listed_year_month[0].to_i
        result_value.listed_month = listed_year_month[1].to_i

        result_value.feature = get_content(selector: "#{company_info_selector}/tr[7]") do |content| # (例)【特色】ＡＶ機器大手。~
          content.gsub("【特色】", "")
        end

        result_value.trend = get_content(selector: "#{company_info_selector}/tr[12]")
        result_value.current_strategy = get_content(selector: "#{company_info_selector}/tr[13]")

        category_and_rank = get_content(selector: "#{company_info_selector}/tr[14]") do |content| # (例)【業種】 娯楽用品 時価総額順位 1/48社
          content.gsub("【業種】", "").gsub(/\/\d+.*$/, "").split(" 時価総額順位 ")
        end
        result_value.category = category_and_rank[0].strip
        result_value.category_rank = category_and_rank[1].to_i

        stock_holder_selector = "#{base_selector}/table[2]/tbody/tr/td[1]/table/tbody"
        result_value.big_stock_holder = get_content(selector: "#{stock_holder_selector}/tr[2]/td[1]")
      end
      result_value
    end

    def get_financial_info_of(stock_code)
      result_value = StockInfoValue.new
      result_value.code = stock_code
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_DataStoreID=DSWPLETsiR001Control&_PageID=WPLETsiR001Idtl50&getFlg=on&_ActionID=goToSeasonReportOfFinanceStatus&s_rkbn=2&s_btype=&ref_from=1&ref_to=20&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=1&qr_suggest=1&qr_sort=1&i_dom_flg=1&i_exchange_code=JPN&i_output_type=4&exchange_code=TKY&stock_sec_code_mul=#{stock_code}")

        performance_rows = accessor.find_elements(:xpath, "//*[@id='main']/div[8]/table[2]/tbody/tr[1]/td[1]/table/tbody/tr")
        result_value.stock_performance_values = performance_rows.map do |performance_row|
          performance_title = get_content(target_element: performance_row, selector: "./td[1]")
          next unless ["連", "◎", "単"].select {|performance_record_prefix| performance_title.include?(performance_record_prefix)}.present?
          next if ["予"].select {|performance_not_record_suffix| performance_title.include?(performance_not_record_suffix)}.present?
          performance_value = StockPerformanceValue.new

          performance_year_and_month = performance_title.match(/\D*(\d+)\D*(\d+).*/) # 連18.12 → [1]18 [2]12
          performance_value.year = performance_year_and_month[1].to_i + 2000
          performance_value.month = performance_year_and_month[2].to_i

          performance_value.net_sales = get_content(target_element: performance_row, selector: "./td[2]") do |content|
            content.gsub(",", "").to_i
          end

          performance_value.operating_income = get_content(target_element: performance_row, selector: "./td[3]") do |content|
            content.gsub(",", "").to_i
          end

          performance_value.ordinary_income = get_content(target_element: performance_row, selector: "./td[4]") do |content|
            content.gsub(",", "").to_i
          end

          performance_value.net_income = get_content(target_element: performance_row, selector: "./td[5]") do |content|
            content.gsub(",", "").to_i
          end
          performance_value
        end.compact

        first_financial_table_selector = "//*[@id='main']/div[8]/table[3]/tbody/tr/td[1]/table[1]/tbody"
        result_value.buy_unit = get_content(selector: "#{first_financial_table_selector}/tr[2]") do |content| # (例)売買単位100株
          content.match(/売買単位(\d+)株/)[1].to_i
        end
        result_value.market_capitalization = get_content(selector: "#{first_financial_table_selector}/tr[3]") do |content| # (例)時価総額	67,834億円[225] 別バージョン：34.1億円
          market_capitalization = content.gsub(",", "")
          if market_capitalization.include?("億")
            market_capitalization.match(/(\d+)\.*\d*億/)[1].to_i.tap{|oku_number| break oku_2_million(oku_number)}
          elsif market_capitalization.include?("兆")
            market_capitalization.match(/(\d+)\.*\d*兆/)[1].to_i.tap{|oku_number| break cho_2_million(oku_number)}
          else
            nil
          end
        end
        result_value.is_nikkei_average_group = get_content(selector: "#{first_financial_table_selector}/tr[3]") do |content| # (例)時価総額	67,834億円[225]
          content.match(/\[225\]/).present?
        end

        second_financial_table_selector = "//*[@id='main']/div[8]/table[3]/tbody/tr/td[3]/table/tbody"
        result_value.total_asset = get_content(selector: "#{second_financial_table_selector}/tr[2]") do |content| # (例)総資産	20,981,586
          content.gsub(",", "").match(/(\d+)/)[1].to_i
        end
        result_value.shareholder_equity = get_content(selector: "#{second_financial_table_selector}/tr[3]") do |content| # (例)自己資本	3,746,377
          content.gsub(",", "").match(/(\d+)/)[1].to_i
        end
        result_value.common_share = get_content(selector: "#{second_financial_table_selector}/tr[5]") do |content| # (例)資本金	874,291
          content.gsub(",", "").match(/(\d+)/)[1].to_i
        end
        result_value.retained_earnings = get_content(selector: "#{second_financial_table_selector}/tr[6]") do |content| # (例)利益剰余金	2,320,586
          content.gsub(",", "").match(/(\d+)/)[1].to_i
        end
      end
      result_value
    end

    private

    def stocks_url_of_industry(sample_industry_url, from, to)
      uri = URI::parse(sample_industry_url)
      params = URI::decode_www_form(uri.query).to_h
      params["ref_from"] = from.to_s
      params["ref_to"] = to.to_s
      uri.query = URI::encode_www_form(params)
      uri.to_s
    end

    def oku_2_million(oku_number)
      raw_number = oku_number * 10_000 ** 2
      raw_number / 1_000_000
    end

    def cho_2_million(oku_number)
      raw_number = oku_number * 10_000 ** 3
      raw_number / 1_000_000
    end
  end
end