class IndexSlackValue
  attr_accessor :index_code, :index_name, :index_price_value

  def initialize(index_code)
    @index_code = index_code
    @index_name = code_2_name(index_code)
  end

  private

  def code_2_name(code)
    case code
      when ::IndexDomain::Codes::NIKKEI_AVERAGE then
        "日経平均"
      when ::IndexDomain::Codes::DOW_AVERAGE then
        "ダウ平均"
      else
        ""
    end
  end
end