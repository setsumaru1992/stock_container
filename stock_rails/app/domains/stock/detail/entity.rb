module Stock::Detail
  class Entity
    class << self
      # Factoryを記載 例：全ての銘柄コードを取得しそれぞれのEntityを生成
    end

    def initialize(code)
      @code = code
    end

    def get_detail_from_web

    end
  end
end