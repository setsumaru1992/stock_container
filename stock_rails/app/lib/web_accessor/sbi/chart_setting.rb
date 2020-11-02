module WebAccessor::Sbi
  class ChartSetting
    attr_reader :range_key, :chart_unit, :first_technical, :second_technical

    def initialize(range_key, chart_unit = nil, first_technical = nil, second_technical = nil)
      @range_key = range_key
      @chart_unit = chart_unit
      @first_technical = first_technical
      @second_technical = second_technical
    end

    def range_tab_idx_for_xpath
      {
        ONE_DAY: 1,
        TWO_DAY: 2,
        FIVE_DAY: 3,
        TEN_DAY: 4,
        THREE_DAY: 5,
        ONE_MONTH: 6,
        TWO_MONTH: 7,
        THREE_MONTH: 8,
        SIX_MONTH: 9,
        ONE_YEAR: 10,
        TWO_YEAR: 11,
        THREE_YEAR: 12,
        FIVE_YEAR: 13,
        TEN_YEAR: 14,
        TWENTY_YEAR: 15
      }[@range_key]
    end

    module Range
      ONE_DAY = :ONE_DAY
      TWO_DAY = :TWO_DAY
      FIVE_DAY = :FIVE_DAY
      THREE_DAY = :THREE_DAY
      TEN_DAY = :TEN_DAY
      ONE_MONTH = :ONE_MONTH
      TWO_MONTH = :TWO_MONTH
      THREE_MONTH = :THREE_MONTH
      SIX_MONTH = :SIX_MONTH
      ONE_YEAR = :ONE_YEAR
      TWO_YEAR = :TWO_YEAR
      THREE_YEAR = :THREE_YEAR
      FIVE_YEAR = :FIVE_YEAR
      TEN_YEAR = :TEN_YEAR
      TWENTY_YEAR = :TWENTY_YEAR
    end

    def chart_unit_select_value
      ChartUnit::SELECT_VALUE[@chart_unit]
    end

    module ChartUnit
      ONE_MINUTE = :ONE_MINUTE
      FIVE_MINUTE = :FIVE_MINUTE
      FIFTY_MINUTE = :FIFTY_MINUTE
      ONE_HOUR = :ONE_HOUR
      ONE_DAY = :ONE_DAY
      ONE_WEEK = :ONE_WEEK
      ONE_MONTH = :ONE_MONTH
      ONE_QUARTER = :ONE_QUARTER

      SELECT_VALUE = {
        ONE_MINUTE => "1",
        FIVE_MINUTE => "5",
        FIFTY_MINUTE => "15",
        ONE_HOUR => "60",
        ONE_DAY => "D",
        ONE_WEEK => "W",
        ONE_MONTH => "M",
        ONE_QUARTER => "Q",
      }
    end

    def first_technical_select_value
      Technical::SELECT_VALUE[@first_technical]
    end

    def second_technical_select_value
      Technical::SELECT_VALUE[@second_technical]
    end

    module Technical
      NONE = :NONE
      # 1つ目
      SINGLE_MOVING_AVERAGE_1LINE = :SINGLE_MOVING_AVERAGE_1LINE
      SINGLE_MOVING_AVERAGE_2LINE = :SINGLE_MOVING_AVERAGE_2LINE
      SINGLE_MOVING_AVERAGE_3LINE = :SINGLE_MOVING_AVERAGE_3LINE
      WEIGHTED_MOVING_AVERAGE_1LINE = :WEIGHTED_MOVING_AVERAGE_1LINE
      WEIGHTED_MOVING_AVERAGE_2LINE = :WEIGHTED_MOVING_AVERAGE_2LINE
      WEIGHTED_MOVING_AVERAGE_3LINE = :WEIGHTED_MOVING_AVERAGE_3LINE
      BOLLINGER_BAND = :BOLLINGER_BAND
      AHL = :AHL
      ICHIMOKU_KINKOHYO = :ICHIMOKU_KINKOHYO
      FIBONACCI_RETRACEMENT = :FIBONACCI_RETRACEMENT
      ENVELOPE = :ENVELOPE
      # 2つ目
      VOLUME = :VOLUME
      ONLINE_VOLUME = :ONLINE_VOLUME
      MACD = :MACD
      SLOW_STOCHASTICS = :SLOW_STOCHASTICS
      FAST_STOCHASTICS = :FAST_STOCHASTICS
      MOMENTUM = :MOMENTUM
      RSI = :RSI
      ROC = :ROC
      COMMODITY_CHANNEL_INDEX = :COMMODITY_CHANNEL_INDEX
      DMI = :DMI
      VOLATILITY = :VOLATILITY
      WILLIAMS_R = :WILLIAMS_R
      SINGLE_MOVING_AVERAGE_ESTRANGEMENT_RATE = :SINGLE_MOVING_AVERAGE_ESTRANGEMENT_RATE
      WEIGHTED_MOVING_AVERAGE_ESTRANGEMENT_RATE = :WEIGHTED_MOVING_AVERAGE_ESTRANGEMENT_RATE
      PSYCHOLOGICAL_LINE = :PSYCHOLOGICAL_LINE
      RCI = :RCI

      SELECT_VALUE = {
        NONE => "None",
        SINGLE_MOVING_AVERAGE_1LINE => "SMA1",
        SINGLE_MOVING_AVERAGE_2LINE => "SMA2",
        SINGLE_MOVING_AVERAGE_3LINE => "SMA3",
        WEIGHTED_MOVING_AVERAGE_1LINE => "WMA1",
        WEIGHTED_MOVING_AVERAGE_2LINE => "WMA2",
        WEIGHTED_MOVING_AVERAGE_3LINE => "WMA3",
        BOLLINGER_BAND => "BOL",
        AHL => "AHL",
        ICHIMOKU_KINKOHYO => "ICHI",
        FIBONACCI_RETRACEMENT => "FIB",
        ENVELOPE => "ENV",
        VOLUME => "V",
        ONLINE_VOLUME => "OV",
        MACD => "MD",
        SLOW_STOCHASTICS => "SS",
        FAST_STOCHASTICS => "FS",
        MOMENTUM => "MT",
        RSI => "RSI",
        ROC => "ROC",
        COMMODITY_CHANNEL_INDEX => "CCI",
        DMI => "DMI",
        VOLATILITY => "VT",
        WILLIAMS_R => "WR",
        SINGLE_MOVING_AVERAGE_ESTRANGEMENT_RATE => "SMAS3",
        WEIGHTED_MOVING_AVERAGE_ESTRANGEMENT_RATE => "WMAS3",
        PSYCHOLOGICAL_LINE => "PSY",
        RCI => "RCI",
      }
    end
  end
end