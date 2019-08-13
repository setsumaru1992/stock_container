module WebAccessor::Sbi
  class StockDetail < Base
    def initialize(user_name: nil, password: nil)
      super(user_name: user_name, password: password)
    end

    def get_company_base_info_of(stock_code)
      result_values = StockDetailValues.new
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_PageID=WPLETsiR001Idtl50&_DataStoreID=DSWPLETsiR001Control&_ActionID=DefaultAID&s_btype=&i_dom_flg=1&i_exchange_code=JPN&i_output_type=4&exchange_code=TKY&ref_from=1&ref_to=20&getFlg=on&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=1&qr_suggest=1&qr_sort=1&stock_sec_code_mul=#{stock_code}")

        base_selector = "//*[@id='main']/div[8]"
        company_info_selector = "#{base_selector}/table[1]/tbody"
        result_values.settlement_month = get_content(selector: "#{company_info_selector}/tr[4]") do |content| # (例)【決算】3月
          content.gsub("【決算】", "").gsub("月", "").to_i
        end

        result_values.established_year = get_content(selector: "#{company_info_selector}/tr[5]") do |content| # (例)【設立】1947.11
          content.gsub("【設立】", "").split(".")[0].to_i
        end

        listed_year_month = get_content(selector: "#{company_info_selector}/tr[6]") do |content| # (例)【上場】1962.1
          content.gsub("【上場】", "").split(".")
        end
        result_values.listed_year = listed_year_month[0].to_i
        result_values.listed_month = listed_year_month[1].to_i

        result_values.feature = get_content(selector: "#{company_info_selector}/tr[7]") do |content| # (例)【特色】ＡＶ機器大手。~
          content.gsub("【特色】", "")
        end

        result_values.trend = get_content(selector: "#{company_info_selector}/tr[12]")
        result_values.current_strategy = get_content(selector: "#{company_info_selector}/tr[13]")

        category_and_rank = get_content(selector: "#{company_info_selector}/tr[14]") do |content| # (例)【業種】 娯楽用品 時価総額順位 1/48社
          content.gsub("【業種】", "").gsub(/\/\d+.*$/, "").split(" 時価総額順位 ")
        end
        result_values.category = category_and_rank[0].strip
        result_values.category_rank = category_and_rank[1].to_i

        stock_holder_selector = "#{base_selector}/table[2]/tbody/tr/td[1]/table/tbody"
        result_values.big_stock_holder = get_content(selector: "#{stock_holder_selector}/tr[2]/td[1]")
      end
      result_values
    end

    def get_finantial_info_of(stock_code)
      result = {}
      access do |accessor|
        visit("https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETsiR001Control&_DataStoreID=DSWPLETsiR001Control&_PageID=WPLETsiR001Idtl50&getFlg=on&_ActionID=goToSeasonReportOfFinanceStatus&s_rkbn=2&s_btype=&ref_from=1&ref_to=20&wstm4130_sort_id=&wstm4130_sort_kbn=&qr_keyword=1&qr_suggest=1&qr_sort=1&i_dom_flg=1&i_exchange_code=JPN&i_output_type=4&exchange_code=TKY&stock_sec_code_mul=#{stock_code}")

      end
      result
    end
  end
end